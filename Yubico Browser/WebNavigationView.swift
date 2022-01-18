//
//  WebNavigationView.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2022-01-17.
//

import SwiftUI
import Combine

struct WebNavigationView: View {
    
    @State private var urlString: String = ""
    @Binding var url: URL?
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isShowingCertificates: Bool
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
                Button(action: {
                    isShowingCertificates.toggle()
                    print("certificates")
                }) {
                    Image(systemName: "key")
                        .font(.system(size: 22, weight: .regular))
                        .rotationEffect(Angle(degrees: 90))
                }
            }
            .padding([.top, .bottom], 0)
        }
        .padding([.leading, .trailing], 20)
        .background(Color(.secondarySystemBackground))
        .onChange(of: url) { url in
            urlString = url?.absoluteString ?? ""
        }
    }
}

//struct WebNavigationView_Previews: PreviewProvider {
//    static var previews: some View {
//        WebNavigationView(url: .constant(URL(string: "https://foo.com/")), canGoBack: .constant(false), isShowingCertificates: .constant(false))
//    }
//}
