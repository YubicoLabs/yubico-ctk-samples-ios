//
//  TokenDriver.swift
//  TokenExtension
//
//  Created by Jens Utbult on 2021-12-10.
//

import CryptoTokenKit

class TokenDriver: TKTokenDriver, TKTokenDriverDelegate {

    func tokenDriver(_ driver: TKTokenDriver, tokenFor configuration: TKToken.Configuration) throws -> TKToken {
        return Token(tokenDriver: self, instanceID: configuration.instanceID)
    }

}
