/*
 * Copyright (C) 2022 Yubico.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


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
