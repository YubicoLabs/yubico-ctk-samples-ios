//
//  TokenSession.swift
//  TokenExtension
//
//  Created by Jens Utbult on 2021-12-10.
//

import CryptoTokenKit

class TokenSession: TKTokenSession, TKTokenSessionDelegate {
    
    // These cases match the YKFPIVKeyType in the YubiKit SDK
    enum KeyType: UInt8 {
        case rsa1024 = 0x06
        case rsa2048 = 0x07
        case eccp256 = 0x11
        case eccp384 = 0x14
        case unknown = 0x00
    }

    func tokenSession(_ session: TKTokenSession, beginAuthFor operation: TKTokenOperation, constraint: Any) throws -> TKTokenAuthOperation {
        // Insert code here to create an instance of TKTokenAuthOperation based on the specified operation and constraint.
        // Note that the constraint was previously established when creating token configuration with keychain items.
        return TKTokenAuthOperation()
    }
    
    func tokenSession(_ session: TKTokenSession, supports operation: TKTokenOperation, keyObjectID: Any, algorithm: TKTokenKeyAlgorithm) -> Bool {
        // Indicate whether the given key supports the specified operation and algorithm.
        return operation == .signData
    }
    
    func tokenSession(_ session: TKTokenSession, sign dataToSign: Data, keyObjectID: Any, algorithm: TKTokenKeyAlgorithm) throws -> Data {
        guard let key = try? session.token.configuration.key(for: keyObjectID), let objectId = keyObjectID as? String else {
            throw "No key for you!"
        }
        
        var possibleKeyType: KeyType? = nil
        if key.keyType == kSecAttrKeyTypeRSA as String {
            if key.keySizeInBits == 1024 {
                possibleKeyType = .rsa1024
            } else if key.keySizeInBits == 2048 {
                possibleKeyType = .rsa2048
            }
        } else if key.keyType == kSecAttrKeyTypeECSECPrimeRandom as String {
            if key.keySizeInBits == 256 {
                possibleKeyType = .eccp256
            } else if key.keySizeInBits == 384 {
                possibleKeyType = .eccp384
            }
        }
        
        guard let keyType = possibleKeyType, let secKeyAlgorithm = algorithm.secKeyAlgorithm else {
            throw NSError(domain: TKErrorDomain, code: TKError.Code.canceledByUser.rawValue, userInfo: nil)
        }
        
        if let pin = try? UserDefaults(suiteName: "group.com.yubico.browser")!.readPin() {
            if YubiKeyPIVSession.shared.yubiKeyConnected {
                if let signedData = YubiKeyPIVSession.shared.sign(objectId: objectId, type: keyType, algorithm: secKeyAlgorithm, message: dataToSign, password: pin) {
                    YubiKeyPIVSession.shared.stop()
                    return signedData
                }
            }
        }
        
        throw NSError(domain: TKErrorDomain, code: TKError.Code.authenticationFailed.rawValue, userInfo: nil)
    }
}
