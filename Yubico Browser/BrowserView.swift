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
    @State var url: URL?
    
    var body: some View {
        VStack {
            NavigationLink(destination: CertificatesView(), isActive: $isShowingCertificatesView) { EmptyView() }
            WebView(url: url)
            WebNavigationView(url: $url, isShowingCertificates: $isShowingCertificatesView)
        }
        .sheet(isPresented: $isShowingCertificatesView) {
            CertificatesView()
        }
    }
}


struct WebView : UIViewRepresentable {
    
    let url: URL?
    let browserModel = BrowserModel()
    
    func makeUIView(context: Context) -> WKWebView  {
        return browserModel.webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = url {
            webView.load(URLRequest(url: url))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView(url: nil)
    }
}
