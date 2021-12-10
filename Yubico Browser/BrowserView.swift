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
                WebView(request: URLRequest(url: URL(string: "https://dain.se/cert.html")!))
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
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    
}


struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView()
    }
}
