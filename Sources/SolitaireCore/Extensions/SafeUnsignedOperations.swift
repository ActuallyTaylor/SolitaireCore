//
//  Uint16+SafeOperations.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 7/31/25.
//

extension UnsignedInteger where Self: FixedWidthInteger {
    mutating func safeAdd(value: Self) {
        if self <= Self.max - value {
            self += value
        } else {
            self = Self.max
        }
    }
    
    mutating func safeSubtract(value: Self) {
        if self >= value {
            self -= value
        } else {
            self = Self.min
        }
    }
}
