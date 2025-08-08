//
//  LoadTests.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 7/31/25.
//

import Testing
@testable import SolitaireCore

struct LoadingTests {
    @Test("Test load binary game", arguments: [
        [
            [], [],
            ["A♠", "2♠", "3♠", "4♠", "5♠", "6♠", "7♠", "8♠", "9♠", "10♠", "J♠", "Q♠", "K♠"],
            ["A♦", "2♦", "3♦", "4♦", "5♦", "6♦", "7♦", "8♦", "9♦", "10♦", "J♦", "Q♦", "K♦"],
            ["A♣", "2♣", "3♣", "4♣", "5♣", "6♣", "7♣", "8♣", "9♣", "10♣", "J♣", "Q♣", "K♣"],
            ["A♥", "2♥", "3♥", "4♥", "5♥", "6♥", "7♥", "8♥", "9♥", "10♥", "J♥", "Q♥", "K♥"],
            [], [], [], [], [], [], []
        ],
    ])
    func testSaveAndLoadBinaryGame(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let savedGame = SolitaireGame.saveGame(game: game)
        
        #expect(!savedGame.isEmpty)
        
        let loadedGame = SolitaireGame.loadGame(from: savedGame)
        #expect(game == loadedGame)
    }
    
    @Test("Test loading a seeded game", arguments: [1, 2, 3, 4, 5])
    func testSeededGames(seed: Int) {
//        let game = SolitaireGame(seed: seed)
//        #expect(game.seed == seed)
    }
}
