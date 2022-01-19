//
//  WebView.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2022-01-18.
//

import Foundation
import WebKit
import SwiftUI
import Combine

struct WebView: UIViewRepresentable {
    
    enum NavigateDirection {
        case forward
        case backward
    }
    
    @Binding var url: URL?
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    
    var navigate: PassthroughSubject<WebView.NavigateDirection, Never>
    @State var cancellable: AnyCancellable?
    
    var webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()

    func makeCoordinator() -> Coordinator {
        Coordinator(url: $url, canGoBack: $canGoBack, canGoForward: $canGoForward)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var url: URL?
        @Binding var canGoBack: Bool
        @Binding var canGoForward: Bool

        init(url: Binding<URL?>, canGoBack: Binding<Bool>, canGoForward: Binding<Bool>) {
            _url = url
            _canGoBack = canGoBack
            _canGoForward = canGoForward
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            url = webView.url
            canGoBack = webView.canGoBack
            canGoForward = webView.canGoForward
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
                
                // Let user select which cert to use, handle pin entry and call the completion handler.
                let alert = UIAlertController.selectCertAndPinEntryAlert(certs: items, completionHandler: completionHandler)
                alert.show()
            case NSURLAuthenticationMethodServerTrust:
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential);
            case NSURLAuthenticationMethodHTTPBasic:
                print("Basic auth")
            default:
                completionHandler(.useCredential, nil)
            }
        }
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        DispatchQueue.main.async {
            self.cancellable = navigate.sink { direction in
                switch direction {
                case .forward:
                    webView.goForward()
                case .backward:
                    webView.goBack()
                }
            }
        }
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = url {
            webView.load(URLRequest(url: url))
        }
    }
}


extension UIAlertController {
    static func selectCertAndPinEntryAlert(certs: [[String : Any]], completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> UIAlertController {
        // Select cert UIAlertController.
        let alert = UIAlertController(title: "Select certificate", message: nil, preferredStyle: .actionSheet)
        certs.forEach { item in
            guard let certData = item["certdata"] as? Data else { return }
            guard let certificate = SecCertificateCreateWithData(nil, certData as CFData) else { return }
            alert.addAction(UIAlertAction(title: certificate.commonName,
                                          style: .default,
                                          handler: { action in
                // Pin entry UIAlertController created after the user selected one of the certs.
                let passwordAlert = UIAlertController(title: "Enter pin", message: nil, preferredStyle: .alert)
                passwordAlert.addTextField { textField in
                    textField.isSecureTextEntry = true
                }
                passwordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    completionHandler(.cancelAuthenticationChallenge, nil)
                })
                passwordAlert.addAction(UIAlertAction(title: "Ok",
                                                      style: .default,
                                                      handler: { action in
                    guard let pin = passwordAlert.textFields?.first?.text else { completionHandler(.cancelAuthenticationChallenge, nil); return }
                    let secIdentity = item["v_Ref"] as! SecIdentity
                    let urlCredential = URLCredential(identity: secIdentity, certificates: nil, persistence: .none)
                    // If this doesn't return a UserDefaults something is broken in the project and we might as well crash.
                    UserDefaults(suiteName: "group.com.yubico.browser")!.writePin(pin)
                    completionHandler(.useCredential, urlCredential)
                }))
                passwordAlert.show()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(.cancelAuthenticationChallenge, nil)
        })
        return alert
    }
}
