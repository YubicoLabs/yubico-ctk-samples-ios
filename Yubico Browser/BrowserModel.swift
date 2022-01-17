//
//  BrowserModel.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2021-12-10.
//

import Foundation
import WebKit
import CryptoTokenKit
import AuthenticationServices

struct SecIdentityIdentifer {
    var identityIdentifer: String
    var identityValue: SecIdentity?
}

class BrowserModel: NSObject, WKNavigationDelegate {
    
    var webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    override init() {
        super.init()
        webView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        switch challenge.protectionSpace.authenticationMethod {
        case NSURLAuthenticationMethodClientCertificate:
            let query: [String:Any] = [kSecAttrAccessGroup as String: kSecAttrAccessGroupToken,
                                       kSecAttrKeyClass as String : kSecAttrKeyClassPrivate,
                                       kSecClass as String : kSecClassIdentity,
                                       kSecReturnAttributes as String : kCFBooleanTrue as Any,
                                       kSecReturnRef as String: kCFBooleanTrue as Any,
                                       kSecMatchLimit as String: kSecMatchLimitAll,
                                       kSecReturnPersistentRef as String: kCFBooleanTrue as Any
            ]
            var result : AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            
            guard status == errSecSuccess, let allItems = result as? [[String: Any]] else {
                let errorDescription = SecCopyErrorMessageString(status, nil)
                print(errorDescription as Any)
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            let items = allItems.filter { item in
                return (item["tkid"] as? String)?.starts(with: "com.yubico.Yubico-Browser") ?? false
            }
            
            let alert = UIAlertController(title: "Select certificate", message: nil, preferredStyle: .actionSheet)
            items.forEach { item in
                guard let certData = item["certdata"] as? Data else { return }
                guard let certificate = SecCertificateCreateWithData(nil, certData as CFData) else { return }
                alert.addAction(UIAlertAction(title: certificate.commonName,
                                              style: .default,
                                              handler: { action in
                    
                    let secIdentity = item["v_Ref"] as! SecIdentity
                    let urlCredential = URLCredential(identity: secIdentity, certificates: nil, persistence: .none)
                    completionHandler(.useCredential, urlCredential)
                }))
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(.cancelAuthenticationChallenge, nil)
            })
            alert.show()
            return
        case NSURLAuthenticationMethodServerTrust:
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential);
        case NSURLAuthenticationMethodHTTPBasic:
            print("Basic auth")
        default:
            completionHandler(.useCredential, nil)
        }
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            
        }
    }
    
    func load(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}



extension UIAlertController {
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController, let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else if let tabVC = controller as? UITabBarController, let selectedVC = tabVC.selectedViewController {
            presentFromController(controller: selectedVC, animated: animated, completion: completion)
        } else if let presented = controller.presentedViewController {
            presentFromController(controller: presented, animated: animated, completion: completion)
        } else {
            controller.present(self, animated: animated, completion: completion);
        }
    }
}
