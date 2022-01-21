//
//  YubiKeyConnection.swift
//  Yubico Browser
//
//  Created by Jens Utbult on 2021-12-09.
//

import Foundation
import YubiKit


class YubiKeyConnection: NSObject {
    private typealias ConnectionContinuation = CheckedContinuation<YKFConnectionProtocol, Never>

    private var nfcConnection: YKFNFCConnection?
    private var accessoryConnection: YKFAccessoryConnection?
    private var continuation: ConnectionContinuation?
    
    override init() {
        super.init()
        YubiKitManager.shared.delegate = self
        YubiKitManager.shared.startAccessoryConnection()
        Thread.sleep(forTimeInterval: 0.2) // wait for lightning to establish a connection
    }
    
    func connection() async -> YKFConnectionProtocol {
        if let connection = accessoryConnection {
            return connection
        }
        YubiKitManager.shared.startNFCConnection()
        return await withCheckedContinuation({ (continuation: ConnectionContinuation) in
            self.continuation = continuation
        })
    }
    
    func close() {
        YubiKitManager.shared.stopNFCConnection()
    }
    
}

extension YKFConnectionProtocol {
    func close() {
        YubiKitManager.shared.stopNFCConnection()
    }
}

extension YubiKeyConnection: YKFManagerDelegate {
    func didConnectNFC(_ connection: YKFNFCConnection) {
        nfcConnection = connection
        continuation?.resume(returning: connection)
        continuation = nil
    }
    
    func didDisconnectNFC(_ connection: YKFNFCConnection, error: Error?) {
        nfcConnection = nil
    }
    
    func didConnectAccessory(_ connection: YKFAccessoryConnection) {
        accessoryConnection = connection
        continuation?.resume(returning: connection)
        continuation = nil
    }
    
    func didDisconnectAccessory(_ connection: YKFAccessoryConnection, error: Error?) {
        accessoryConnection = nil
        continuation?.resume(returning: connection)
        continuation = nil
    }
}

