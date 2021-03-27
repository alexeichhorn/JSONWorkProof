//
//  DecodeError.swift
//  
//
//  Created by Alexander Eichhorn on 27.03.21.
//

import Foundation

extension JWP {
    
    public enum DecodeError: Error {
        case invalidFormat
        case invalidProof
        case expired
    }
    
}
