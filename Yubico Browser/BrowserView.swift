//
//  BrowserView.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2021-12-09.
//

import SwiftUI
import SafariServices
import WebKit

struct BrowserView: View {
    
    @State private var isShowingCertificatesView = false
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: CertificatesView(), isActive: $isShowingCertificatesView) { EmptyView() }
                WebView(request: URLRequest(url: URL(string: "https://client.badssl.com/")!))
//                WebView(request: URLRequest(url: URL(string: "https://dain.se/cert.html")!))
            }
            .navigationTitle("Yubico Browser")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button( "Certificates") {
                        self.isShowingCertificatesView = true
                    }
                }
            }
        }
    }
}


struct WebView : UIViewRepresentable {
    
    let request: URLRequest
    let browserModel = BrowserModel()
    
    func makeUIView(context: Context) -> WKWebView  {
        return browserModel.webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(request)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView()
    }
}
