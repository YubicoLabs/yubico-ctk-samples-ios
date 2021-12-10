//
//  Token.swift
//  TokenExtension
//
//  Created by Jens Utbult on 2021-12-10.
//

import CryptoTokenKit

class Token: TKToken, TKTokenDelegate {

    func createSession(_ token: TKToken) throws -> TKTokenSession {
        return TokenSession(token:self)
    }

}
