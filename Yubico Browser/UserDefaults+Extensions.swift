//
//  UserDefaults+Extensions.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2022-01-19.
//

import Foundation

extension UserDefaults {
    
    static let pinKey = "pinKey"
    
    func writePin(_ pin: String) {
        self.set(pin, forKey: UserDefaults.pinKey)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.removeObject(forKey: UserDefaults.pinKey)
        }
    }
    
    func readPin() throws -> String {
        let timeout = Date(timeIntervalSinceNow: 60)
        while(timeout > Date()) {
            Thread.sleep(forTimeInterval: 0.2)
            if let pin = self.string(forKey: UserDefaults.pinKey) {
                return pin
            }
        }
        throw "Read pin timeout"
    }
}

extension String: Error {}
