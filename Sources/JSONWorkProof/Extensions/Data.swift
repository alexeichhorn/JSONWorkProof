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
        Base64.encodeString(bytes: [UInt8](self), options: [.base64UrlAlphabet, .omitPaddingCharacter])
    }
    
    func base64urlEncoded() -> Data {
        let bytes = Base64.encodeBytes(bytes: [UInt8](self), options: [.base64UrlAlphabet, .omitPaddingCharacter])
        return Data(bytes)
    }
    
    
    init(minimalRepresentationOf value: UInt64) {
        var value = value
        let zeroBytesCount = value.leadingZeroBitCount / 8
        self = Data(bytes: &value, count: MemoryLayout<UInt64>.size - zeroBytesCount)
    }
}
