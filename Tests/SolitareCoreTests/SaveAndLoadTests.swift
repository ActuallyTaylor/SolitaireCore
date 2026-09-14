//
//  SaveAndLoadTests.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 7/31/25.
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
    
    @Test("Seed loads the same in binary games", arguments: [
        13478432, 314921, 31494832, 123491820394, 134, 1, 0
    ])
    func testBinarySaveLoadsTheSameGame(seed: UInt64) {
        let game = SolitaireGame(seed: seed)
        let savedGame = SolitaireGame.saveGame(game: game)
                
        let loadedGame = SolitaireGame.loadGame(from: savedGame)

        #expect(game == loadedGame)
    }
    
    @Test("Swift standard library shuffle function matches SolitaireCore's stable implementation.", arguments: [
        0, 1, 645, 73140423590, 14845, 1231, 31124, UInt64.max - 1, UInt64.max
    ])
    func testShuffleFunctionDrift(seed: UInt64) throws {
        var generatorForStandard = SeededRandomNumberGenerator(seed: seed)
        var generatorForStable = SeededRandomNumberGenerator(seed: seed)

        let values = [0, 1, 2, 3, 4, 5]
        var swiftStandardShuffleArray = values
        var stableShuffleArray = values
        
        swiftStandardShuffleArray.shuffle(using: &generatorForStandard)
        stableShuffleArray.shuffle(using: &generatorForStable)

        #expect(swiftStandardShuffleArray == stableShuffleArray)
    }
}

struct BinaryTests {
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
    
    
    @Test("The binary size of a solitaire game should match what is declared in byteCount")
    func solitaireGameBinarySizeIsStable() {
        let gameRep = [
            [], [],
            ["AS", "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS"],
            ["AD", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD"],
            ["AC", "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC"],
            ["AH", "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH", "KH"],
            [], [], [], [], [], [], []
        ]
        let game = SolitaireGame.loadGame(from: gameRep)

        let savedGame = SolitaireGame.saveGame(game: game)

        // The current byte count as of version 4.
        #expect(SolitaireGame.byteCount == 83)
        #expect(savedGame.count == SolitaireGame.byteCount)
    }
}
