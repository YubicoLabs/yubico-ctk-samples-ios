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
