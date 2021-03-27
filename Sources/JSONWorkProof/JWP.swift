//
//  JWP.swift
//  
//
//  Created by Alexander Eichhorn on 25.03.21.
//

import Foundation
import CryptoKit
import os.log

public struct JWP {
    
    public let difficulty: UInt
    
    public let saltLength: Int
    
    public init(difficulty: UInt = 20, saltLength: Int = 16) {
        self.difficulty = difficulty
        self.saltLength = saltLength
    }
    
    
    private let log = OSLog(subsystem: "JSONWorkProof", category: "JWP")
    
    
    // MARK: - Encode
    
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
        
        var baseHasher = SHA256()
        baseHasher.update(data: challengeData)
        
        var counter: UInt64 = 0
        
        while true {
            let proof = Data(minimalRepresentationOf: counter)
            let encodedProof = proof.base64urlEncoded()
            
            var hasher = baseHasher
            hasher.update(data: encodedProof)
            let digest = hasher.finalize()
            
            if digest.isZeroPrefixed(withBits: difficulty) {
                return challenge + proof.base64urlEncodedString()
            }
            
            counter += 1
        }
    }
    
    
    // MARK: - Decode
    
    /// - parameter expirationRange: defines accepted expiration dates. Can be set to `DateRange.unlimited` to disregard. (Default: expiration should lie in next 30 minutes)
    public func decode(_ stamp: String, verify: Bool = true, expirationRange: DateRange = DateRange(fromNow: 1800)) throws -> [String: Codable] {
        
        let components = stamp.components(separatedBy: ".")
        guard components.count == 3 else { throw DecodeError.invalidFormat }
        
        let encodedHeader = components[0]
        let encodedBody = components[1]
        
        guard let headerData = Data(base64urlEncoded: encodedHeader),
              let bodyData = Data(base64urlEncoded: encodedBody) else { throw DecodeError.invalidFormat }
        
        struct BodyWrapper: Decodable {
            let exp: Date?
        }
        
        let header: Header
        let body: [String: AnyCodable]
        let bodyWrapper: BodyWrapper
        
        do {
            header = try JSONDecoder.default.decode(Header.self, from: headerData)
            body = try JSONDecoder.default.decode([String: AnyCodable].self, from: bodyData)
            bodyWrapper = try JSONDecoder.default.decode(BodyWrapper.self, from: bodyData)
        } catch let error {
            os_log("Error while decoding header and body: %{public}@", log: log, type: .error, error.localizedDescription)
            throw DecodeError.invalidFormat
        }
        
        guard verify else {
            return body
        }
        
        // TODO: check algorithm in header
        
        // check proof
        
        let digest = SHA256.hash(data: stamp.data(using: .utf8)!)
        
        guard digest.isZeroPrefixed(withBits: difficulty) else {
            throw DecodeError.invalidProof
        }
        
        
        // check expiration range
        
        let expiration = bodyWrapper.exp ?? Date(timeIntervalSince1970: 0)
        
        guard expirationRange.contains(expiration) else {
            throw DecodeError.expired
        }
        
        return body.mapValues { $0.value }
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
