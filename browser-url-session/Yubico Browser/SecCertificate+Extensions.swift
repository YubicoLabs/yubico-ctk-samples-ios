//
//  SecCertificate+Extensions.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2022-01-21.
//


import Foundation
import CommonCrypto
import CryptoKit

extension SecCertificate: Equatable {
    
    var commonName: String? {
        var name: CFString?
        SecCertificateCopyCommonName(self, &name)
        return name as String?
    }
    
    func tokenObjectId() -> String {
        let data = SecCertificateCopyData(self) as Data
        return data.sha256Hash().map { String(format: "%02X", $0) }.joined()
    }
    
    func publicKey() -> SecKey? {
        return SecCertificateCopyKey(self)
    }
    
    public static func ==(lhs: SecCertificate, rhs: SecCertificate) -> Bool {
        return lhs.tokenObjectId() == rhs.tokenObjectId()
    }
}

extension Data {
    func sha256Hash() -> Data {
        let digest = SHA256.hash(data: self)
        let bytes = Array(digest.makeIterator())
        return Data(bytes)
    }
}