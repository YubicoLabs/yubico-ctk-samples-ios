//
//  TokenSession.swift
//  TokenExtension
//
//  Created by Jens Utbult on 2021-12-10.
//

import CryptoTokenKit

extension String: Error {}

class TokenSession: TKTokenSession, TKTokenSessionDelegate {
    
    // These cases match the YKFPIVKeyType in the SDK
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
        
        let pin = "123456"
        if YubiKeyPIVSession.shared.yubiKeyConnected {
            if let signedData = YubiKeyPIVSession.shared.sign(objectId: objectId, type: keyType, algorithm: secKeyAlgorithm, message: dataToSign, password: pin) {
                YubiKeyPIVSession.shared.stop()
                return signedData
            }
        } else {
            
        }
        
        throw NSError(domain: TKErrorDomain, code: TKError.Code.authenticationFailed.rawValue, userInfo: nil)
    }
    
    func tokenSession(_ session: TKTokenSession, decrypt ciphertext: Data, keyObjectID: Any, algorithm: TKTokenKeyAlgorithm) throws -> Data {
        var plaintext: Data?
        
        // Insert code here to decrypt the ciphertext using the specified key and algorithm.
        plaintext = nil
        
        if let plaintext = plaintext {
            return plaintext
        } else {
            // If the operation failed for some reason, fill in an appropriate error like objectNotFound, corruptedData, etc.
            // Note that responding with TKErrorCodeAuthenticationNeeded will trigger user authentication after which the current operation will be re-attempted.
            throw NSError(domain: TKErrorDomain, code: TKError.Code.authenticationNeeded.rawValue, userInfo: nil)
        }
    }
    
    func tokenSession(_ session: TKTokenSession, performKeyExchange otherPartyPublicKeyData: Data, keyObjectID objectID: Any, algorithm: TKTokenKeyAlgorithm, parameters: TKTokenKeyExchangeParameters) throws -> Data {
        var secret: Data?
        
        // Insert code here to perform Diffie-Hellman style key exchange.
        secret = nil
        
        if let secret = secret {
            return secret
        } else {
            // If the operation failed for some reason, fill in an appropriate error like objectNotFound, corruptedData, etc.
            // Note that responding with TKErrorCodeAuthenticationNeeded will trigger user authentication after which the current operation will be re-attempted.
            throw NSError(domain: TKErrorDomain, code: TKError.Code.authenticationNeeded.rawValue, userInfo: nil)
        }
    }
}
