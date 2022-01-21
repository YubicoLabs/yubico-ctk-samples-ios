//
//  CertificatesView.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2021-12-09.
//

import SwiftUI

struct CertificatesView: View {
    
    @StateObject var model = CertificatesModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
        HStack(spacing: 0) {
            Spacer()
            Button("Dismiss") {
                dismiss()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        List() {
            Section("Certificates on device") {
                if !model.deviceCertificates.isEmpty {
                    ForEach(model.deviceCertificates) {
                        DeviceCertificateRow(credential: $0, model: model)
                    }
                } else {
                    Text("No certificates on device").modifier(CenterModifier())
                }
            }
            Section("Certificates on YubiKey") {
                if !model.yubiKeyCertificates.isEmpty {
                    ForEach(model.yubiKeyCertificates) {
                        YubiKeyCertificateRow(credential: $0, model: model)
                    }
                } else {
                    Text("No certificates on YubiKey").modifier(CenterModifier())
                }
            }
        }
        }
    }
}

struct DeviceCertificateRow : View {
    
    let credential: Certificate
    let model: CertificatesModel
    
    @MainActor init(credential: Certificate, model: CertificatesModel) {
        self.credential = credential
        self.model = model
    }

    var body: some View {
        HStack {
            Text(credential.name).lineLimit(1)
            Spacer()
            Button {
                model.removeFromDevice(cert: credential.certificate)
            } label: {
                Image(systemName: "minus.circle")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
            .dynamicTypeSize(.large)
        }
    }
}

struct YubiKeyCertificateRow : View {
    
    let credential: Certificate
    let model: CertificatesModel
    
    @MainActor init(credential: Certificate, model: CertificatesModel) {
        self.credential = credential
        self.model = model
    }

    var body: some View {
        HStack {
            Text(credential.name).lineLimit(1)
            Spacer()
            Button {
                if !credential.isStoredOnDevice {
                    model.addToDevice(cert: credential.certificate)
                }
            } label: {
                Image(systemName: credential.isStoredOnDevice ? "checkmark.circle" : "plus.circle")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
            .dynamicTypeSize(.large)
        }
    }
}

struct CenterModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}
