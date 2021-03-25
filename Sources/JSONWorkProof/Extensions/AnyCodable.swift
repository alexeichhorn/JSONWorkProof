//
//  AnyCodable.swift
//  
//
//  Created by Alexander Eichhorn on 26.03.21.
//

import Foundation

public struct AnyCodable: Codable { // code partially from github.com/Flight-School/AnyCodable
    let value: Codable
    
    init(_ value: Codable) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.init(Optional<Self>.none)
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array)
            //self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary)
            //self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
}

fileprivate extension Encodable {
    
    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
    
}
