//
//  TestSafeOperations.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 7/31/25.
//

import Testing
@testable import SolitaireCore

struct TestSafeOperations {
    @Test("Test underflow subtraction", arguments: [
        (value: 10, subtract: 20),
        (value: UInt16.min, subtract: UInt16.max),
        (value: UInt16.max, subtract: UInt16.max),
    ])
    func testSubtract(config: (value: UInt16, subtract: UInt16)) {
        var int: UInt16 = config.value
        int.safeSubtract(value: config.subtract)
    }
    
    @Test("Test overflow adddition", arguments: [
        (value: (UInt16.max - 1), add: UInt16(20)) // The compiler complains because the 20 doesn't have a type
    ])
    func testAddition(config: (value: UInt16, add: UInt16)) {
        var int: UInt16 = config.value
        int.safeAdd(value: config.add)
    }

}
