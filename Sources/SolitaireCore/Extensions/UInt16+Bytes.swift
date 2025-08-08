//
//  UInt16+Bytes.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 7/31/25.
//

extension UInt16 {
    var bigEndianBytes: [UInt8] {
        return [
            UInt8((self >> 8) & 0xFF), // Most significant byte
            UInt8(self & 0xFF) // Least significant byte
        ]
    }
    
    init(from data: [UInt8]) {
        let msb = UInt16(data[0])
        let lsb = UInt16(data[1])
        
        self = (msb << 8) | lsb
    }
}
