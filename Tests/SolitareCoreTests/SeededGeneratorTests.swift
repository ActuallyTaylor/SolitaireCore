//
//  SeededGeneratorTests.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 9/13/26.
//

import Testing
@testable import SolitaireCore

struct SeededGeneratorTests {
    @Test("Make sure a seed always produces the same sequence of values.", arguments: [
        0, 1, 139478, 34247823, 23478324, UInt64.max - 1, UInt64.max
    ])
    func seedAlwaysProducesSameSequence(seed: UInt64) {
        let sequenceLength = 100
        var generatorOne = SeededRandomNumberGenerator(seed: seed)
        var generatorTwo = SeededRandomNumberGenerator(seed: seed)
        
        var sequenceOne: [UInt64] = []
        var sequenceTwo: [UInt64] = []
        
        for _ in 0..<sequenceLength {
            sequenceOne.append(generatorOne.next())
            sequenceTwo.append(generatorTwo.next())
        }
        
        #expect(sequenceOne.count == sequenceLength, "Sequence one should have have \(sequenceLength) elements")
        #expect(sequenceTwo.count == sequenceLength, "Sequence two should have have \(sequenceLength) elements")
        #expect(sequenceOne == sequenceTwo, "Sequence one and two should be identical")
        #expect(generatorOne == generatorTwo, "Generators should have the exact same internal state")
    }
}
