//
//  ContentView.swift
//  Yubico Browseer
//
//  Created by Jens Utbult on 2022-01-21.
//

import SwiftUI
import Combine


struct ContentView: View {
    
    @State var url: URL?
    @State var canGoBack = false
    @State var canGoForward = false
    private var didNavigate = PassthroughSubject<WebView.NavigateDirection, Never>()
    
    var body: some View {
        VStack(spacing: 0) {
            WebView(url: $url, canGoBack: $canGoBack, canGoForward: $canGoForward, navigate: didNavigate)
            WebNavigationView(url: $url, canGoBack: $canGoBack, canGoForward: $canGoForward, navigate: didNavigate)
        }    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
