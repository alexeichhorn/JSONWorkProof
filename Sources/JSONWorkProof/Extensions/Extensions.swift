//
//  File.swift
//  
//
//  Created by Alexander Eichhorn on 25.03.21.
//

import Foundation

extension JSONEncoder {
    
    static var `default`: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }
    
}
