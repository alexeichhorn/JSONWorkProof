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
        let encodedSalt = salt.base64urlEncodedString()
        
        let challenge = "\(encodedHeader).\(encodedBody).\(encodedSalt)"
        let challengeData = challenge.data(using: .utf8)!
        
        var counter: UInt64 = 0
        
        while true {
            let proof = Data(minimalRepresentationOf: counter)
            let encodedProof = proof.base64urlEncodedString()
            
            var hasher = SHA256()
            hasher.update(data: challengeData)
            hasher.update(data: encodedProof.data(using: .utf8)!)
            let digest = hasher.finalize()
            
            if digest.isZeroPrefixed(withBits: difficulty) {
                return challenge + encodedProof
            }
            
            counter += 1
        }
    }
    
    
    // MARK: -
    
    private func generateSalt() -> Data {
        var data = Data(count: saltLength)
        
        let result = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, saltLength, $0.baseAddress!)
        }
        guard result == errSecSuccess else { fatalError("Failed to generate salt") }
        
        return data
    }
    
}
