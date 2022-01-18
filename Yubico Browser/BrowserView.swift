//
//  BrowserView.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2021-12-09.
//

import SwiftUI
import SafariServices
import WebKit
import Combine

struct BrowserView: View {
    
    @State private var isShowingCertificatesView = false
    @State var url: URL?
    @State var canGoBack = false
    @State var canGoForward = false
    private var didNavigate = PassthroughSubject<WebView.NavigateDirection, Never>()
    
    var body: some View {
        VStack(spacing: 0) {
            WebView(url: $url, canGoBack: $canGoBack, canGoForward: $canGoForward, navigate: didNavigate)
            WebNavigationView(url: $url, canGoBack: $canGoBack, canGoForward: $canGoForward, isShowingCertificates: $isShowingCertificatesView, navigate: didNavigate)
        }
        .sheet(isPresented: $isShowingCertificatesView) {
            CertificatesView()
        }
    }
}
