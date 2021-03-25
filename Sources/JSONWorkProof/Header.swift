//
//  Header.swift
//  
//
//  Created by Alexander Eichhorn on 25.03.21.
//

import Foundation

struct Header: Codable {
    
    let typ: String
    let alg: Algorithm
    let dif: UInt
    
    enum Algorithm: String, Codable {
        case SHA256
        case SHA1
    }
    
    init(type: String = "JWP", algorithm: Algorithm = .SHA256, difficulty: UInt) {
        self.typ = type
        self.alg = algorithm
        self.dif = difficulty
    }
    
}
