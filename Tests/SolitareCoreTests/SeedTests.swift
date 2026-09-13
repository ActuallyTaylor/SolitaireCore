//
//  SeedTests.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 9/13/26.
//

import Testing
@testable import SolitaireCore

struct SeedTests {
    @Test("Test the same seed always produces the same game", arguments: [
        0, 1, 3, 4, 5, 6, 10314324, 523491238912389, 124389213, 13412579, 94594
    ])
    func testSeedProducesSameDeck(seed: SeedInteger) {
        let game1 = SolitaireGame(seed: seed)
        let game2 = SolitaireGame(seed: seed)
        #expect(game1 == game2)
    }
}
