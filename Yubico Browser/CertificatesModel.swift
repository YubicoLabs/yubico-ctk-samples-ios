//
//  CertificatesModel.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2021-12-09.
//

import Foundation
import YubiKit

struct Certificate: Identifiable, Equatable {
    let certificate: SecCertificate
    var name: String {
        return certificate.commonName ?? "Missing name"
    }
    var id: String {
        return certificate.tokenObjectId()
    }
    var isStoredOnDevice: Bool
}

@MainActor
class CertificatesModel: ObservableObject {
    @Published private(set) var yubiKeyCertificates = [Certificate]()
    @Published private(set) var deviceCertificates = [Certificate]()
    @Published private(set) var errorMessage: String?
    
    let yubiKeyConnection = YubiKeyConnection()
    let tokenCertificatesStorage = TokenCertificateStorage()
    
    init() {
        Task {
            readCertificatesOnDevice()
            do {
                let connection = await yubiKeyConnection.connection()
                let session = try await connection.pivSession()
                let certificates = try await session.readCertificates()
                updateYubiKeyCertificates(with: certificates)
                YubiKitManager.shared.stopNFCConnection(withMessage: "Read certificates from YubiKey" )
            } catch {
                YubiKitManager.shared.stopNFCConnection(withErrorMessage: error.localizedDescription )
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func readCertificatesOnDevice() {
        let certificates = tokenCertificatesStorage.listTokenCertificates()
        deviceCertificates = certificates.map { Certificate(certificate: $0, isStoredOnDevice: true) }
    }
    
    func updateYubiKeyCertificates(with certificates: [Certificate]) {
        yubiKeyCertificates = certificates.map { certificate in
            let isStoredOnDevice = deviceCertificates.contains(where: { certOnDevice in certOnDevice.id == certificate.id } )
            return Certificate(certificate: certificate.certificate, isStoredOnDevice: isStoredOnDevice)
        }
    }
    
    func addToDevice(cert: SecCertificate) {
        let error = tokenCertificatesStorage.storeTokenCertificate(certificate: cert)
        errorMessage = error?.localizedDescription
        readCertificatesOnDevice()
        updateYubiKeyCertificates(with: yubiKeyCertificates)
    }
    
    func removeFromDevice(cert: SecCertificate) {
        _ = tokenCertificatesStorage.removeTokenCertificate(certificate: cert)
        readCertificatesOnDevice()
        updateYubiKeyCertificates(with: yubiKeyCertificates)
    }
    
    deinit {
        print("deinit CertificatesModel")
    }
}

extension YKFPIVSession {
    func readCertificates() async throws -> [Certificate] {
        let authCert = try await self.readCertificate(in: .authentication)
        let signCert = try await self.readCertificate(in: .signature)
        let keyManagementCert = try await self.readCertificate(in: .keyManagement)
        let cardAuthCert = try await self.readCertificate(in: .cardAuth)
        return [authCert, signCert, keyManagementCert, cardAuthCert].compactMap { $0 }
    }
    
    func readCertificate(in slot: YKFPIVSlot) async throws -> Certificate? {
        let certificate: Certificate
        do {
            let secCertificate: SecCertificate = try await self.certificate(in: slot)
            certificate = Certificate(certificate: secCertificate, isStoredOnDevice: false)
        } catch {
            if (error as NSError).code == 0x6a82 { // return nil if the slot is empty
                return nil
            } else {
                throw error
            }
        }
        return certificate
    }
}
