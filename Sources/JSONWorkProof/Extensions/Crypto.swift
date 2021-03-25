//
//  Crypto.swift
//  
//
//  Created by Alexander Eichhorn on 26.03.21.
//

import Foundation
import CryptoKit

extension Digest {
    
    func isZeroPrefixed(withBits bitCount: UInt) -> Bool {
        
        var bitCount = bitCount
        
        for byte in self {
            if bitCount == 0 { return true }
            
            if bitCount >= 8 {
                guard byte == 0 else { return false }
                bitCount -= 8
            } else {
                return byte.leadingZeroBitCount >= bitCount
            }
        }
        
        return bitCount == 0
    }
    
}
