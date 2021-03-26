//
//  Data.swift
//  
//
//  Created by Alexander Eichhorn on 26.03.21.
//

import Foundation

extension Data {
    
    init?(base64urlEncoded input: String) {
        var base64 = input
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 = base64.appending("=")
        }
        self.init(base64Encoded: base64)
    }
    
    func base64urlEncodedString() -> String {
        autoreleasepool {
            var result = self.base64EncodedString()
            result = result.replacingOccurrences(of: "+", with: "-")
            result = result.replacingOccurrences(of: "/", with: "_")
            result = result.replacingOccurrences(of: "=", with: "")
            return result
        }
    }
    
    
    init(minimalRepresentationOf value: UInt64) {
        var bytes = [UInt8](repeating: 0, count: 8)
        var value = value
        
        for i in 0..<8 {
            bytes[i] = UInt8(value & 0xFF)
            value >>= 8
        }
        
        guard let lastByte = bytes.lastIndex(where: { $0 != 0 }) else {
            self = Data()
            return
        }
        
        self = Data(bytes[0...lastByte])
    }
}
