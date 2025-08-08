//
//  SeededRandomNumberGenerator.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 8/6/25.
//

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = UInt64(seed)
    }

    mutating func next() -> UInt64 {
        state ^= state << 21
        state ^= state >> 35
        state ^= state << 4
        return state &* 2685821657736338717 &+ 1
    }
}
