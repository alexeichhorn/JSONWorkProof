//
//  JWP.swift
//  
//
//  Created by Alexander Eichhorn on 25.03.21.
//

import Foundation
import CryptoKit

public struct JWP {
    
    public let difficulty: UInt
    
    public let saltLength: Int
    
    public init(difficulty: UInt = 20, saltLength: Int = 16) {
        self.difficulty = difficulty
        self.saltLength = saltLength
    }
    
    public func generate(claims: [String: Codable], expiration: Date? = Date() + 5*60) throws -> String {
        
        let header = Header(algorithm: .SHA256, difficulty: difficulty)
        
        var claims = claims
        
        if let expiration = expiration, claims["exp"] == nil {
            claims["exp"] = expiration
        }
        
        let body = try JSONEncoder.default.encode(claims.mapValues { AnyCodable($0) })
        
        let encodedHeader = (try JSONEncoder.default.encode(header)).base64urlEncodedString()
        let encodedBody = body.base64urlEncodedString()
        
        let salt = generateSalt()
        
        let challenge = "\(encodedHeader).\(encodedBody).\(salt)"
        
        var counter: UInt64 = 0
        
        while true {
            let encodedCounter = String(format: "%2x", counter).trimmingCharacters(in: .whitespaces)
            let stamp = challenge + encodedCounter
            
            let digest = SHA256.hash(data: stamp.data(using: .utf8)!)
            
            if digest.isZeroPrefixed(withBits: difficulty) {
                return stamp
            }
            
            counter += 1
        }
    }
    
    
    // MARK: -
    
    private func generateSalt() -> String {
        let charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<saltLength).map { _ in charset.randomElement()! })
    }
    
}
