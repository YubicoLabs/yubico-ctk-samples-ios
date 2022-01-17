//
//  WebNavigationView.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2022-01-17.
//

import SwiftUI

struct WebNavigationView: View {
    
    @State private var urlString: String = ""
    @Binding var url: URL?
    @Binding var isShowingCertificates: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("Website name", text: $urlString, onCommit: {
                guard let possibleURL = URL(string: urlString), UIApplication.shared.canOpenURL(possibleURL) else {
                    url = nil; return
                }
                url = possibleURL
            })
                .disableAutocorrection(true)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .padding()
                .background(Color(.secondarySystemBackground))
            
            HStack(spacing: 20) {
                Button(action: {
                    print("back")
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 25, weight: .medium))
                }
                Button(action: {
                    print("forward")
                }) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 25, weight: .medium))
                }
                Spacer()
                Button(action: {
                    isShowingCertificates.toggle()
                    print("certificates")
                }) {
                    Image(systemName: "key")
                        .font(.system(size: 25, weight: .medium))
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
        }
    }
}

struct WebNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        WebNavigationView(url: .constant(URL(string: "https://foo.com/")), isShowingCertificates: .constant(false))
    }
}
