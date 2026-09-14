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
            ["AS", "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS"],
            ["AD", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD"],
            ["AC", "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC"],
            ["AH", "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH", "KH"],
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
