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

struct WebNavigationView: View {
    
    @State private var urlString: String = ""
    @Binding var url: URL?
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    var navigate: PassthroughSubject<WebView.NavigateDirection, Never>

    var body: some View {
        VStack(spacing: 0) {
            TextField("Website name", text: $urlString, onCommit: {
                let possibleURL: URL?
                if urlString.lowercased().starts(with: "https://") || urlString.lowercased().starts(with: "http://") {
                    possibleURL = URL(string: urlString)
                } else {
                    possibleURL = URL(string: "https://\(urlString)")
                }
                guard let possibleURL = possibleURL, UIApplication.shared.canOpenURL(possibleURL) else {
                    url = nil; return
                }
                url = possibleURL
            })
                .disableAutocorrection(true)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom, 10)
                .padding(.top, 15)
            
            HStack(spacing: 50) {
                Button(action: {
                    navigate.send(.backward)
                    print("back")
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 22, weight: .regular))
                }
                .disabled(canGoBack == false)
                Button(action: {
                    navigate.send(.forward)
                    print("forward")
                }) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 22, weight: .regular))
                }
                .disabled(canGoForward == false)
                Spacer()
            }
            .padding([.top, .bottom], 0)
        }
        .padding([.leading, .trailing], 20)
        .background(Color(.secondarySystemBackground))
        .onChange(of: url) { url in
        }
    }
}

struct WebNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        WebNavigationView(url: .constant(URL(string: "https://foo.com/")),
                          canGoBack: .constant(true),
                          canGoForward: .constant(false),
                          navigate: PassthroughSubject<WebView.NavigateDirection, Never>())
    }
}
