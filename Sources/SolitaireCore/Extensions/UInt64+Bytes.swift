//
//  UInt64+Bytes.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 9/13/26.
//

extension UInt64 {
    var bigEndianBytes: [UInt8] {
        return [
            UInt8((self >> 56) & 0xFF),
            UInt8((self >> 48) & 0xFF),
            UInt8((self >> 40) & 0xFF),
            UInt8((self >> 32) & 0xFF),
            UInt8((self >> 24) & 0xFF),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8(self & 0xFF)
        ]
    }
    
    init(from data: [UInt8]) {
        guard data.count >= 8 else { self = 0; return }
        
        let byte1 = UInt64(data[0])
        let byte2 = UInt64(data[1])
        let byte3 = UInt64(data[2])
        let byte4 = UInt64(data[3])
        let byte5 = UInt64(data[4])
        let byte6 = UInt64(data[5])
        let byte7 = UInt64(data[6])
        let byte8 = UInt64(data[7])
                 
        self = (byte1 << 56) | (byte2 << 48) | (byte3 << 40) | (byte4 << 32) | (byte5 << 24) | (byte6 << 16) | (byte7 << 8) | byte8
    }
}
