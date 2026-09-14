//
//  GameStateTests.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

import Testing
@testable import SolitaireCore

struct GameStateTests {
    @Test("Test valid completed game", arguments: [
        [
            [], [],
            ["AS", "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS"],
            ["AD", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD"],
            ["AC", "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC"],
            ["AH", "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH", "KH"],
            [], [], [], [], [], [], []
        ],
    ])
    func testCompletedGame(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        #expect(game.checkIsGameSolved())
        #expect(game.isSolved)
    }
    
    @Test("Test invalid completed game", arguments: [
        [
            [], [],
            ["AS", "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS"],
            ["AD", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD"],
            ["AC", "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC"],
            ["AH", "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H"],
            ["10H", "JH", "QH", "KH"], [], [], [], [], [], []
        ],
        [
            // Swap some of the suits around
            [], [],
            ["AS", "2D", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS"],
            ["AD", "2S", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD"],
            ["AC", "2H", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC"],
            ["AH", "2C", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH", "KH"],
            [], [], [], [], [], [], []
        ],

    ])
    func testInvalidCompletedGame(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        #expect(!game.checkIsGameSolved())
        #expect(!game.isSolved)
    }
    
    @Test("Test number of valid moves", arguments: [
        // Simple single move, Red -> Black
        (gameRep: [[], [], [], [], [], [], ["3S"], ["2H"], [], [], [], [], []], moveCount: 1),
        // One destination (Black) and two possible moves (Red)
        (gameRep: [[], [], [], [], [], [], ["3S"], ["2H"], [], ["2D"], [], [], []], moveCount: 2),
        // Two black destinations, with two red cards. Four possible moves
        (gameRep: [[], [], [], [], [], [], ["3S"], ["2H"], ["3C"], ["2D"], [], [], []], moveCount: 4),
        // One move into foundation
        (gameRep: [[], [], ["AH"], [], [], [], [], ["2H"], [], [], [], [], []], moveCount: 1),
        // Two possible foundation moves
        (gameRep: [[], [], ["2H"], ["JC"], [], [], [], ["3H"], ["QC"], [], [], [], []], moveCount: 2),
        // Move ace into any of the four foundations
        (gameRep: [[], [], [], [], [], [], [], ["AH"], [], [], [], [], []], moveCount: 4),
        // Move king into any of the six other foundations
        (gameRep: [[], [], [], [], [], [], [], ["KH"], [], [], [], [], []], moveCount: 6),
        // Move king from hand to any of the seven foundation + restock
        (gameRep: [[], ["KH"], [], [], [], [], [], [], [], [], [], [], []], moveCount: 8),
        // Test draw card from stock
        (gameRep: [["QH", "KH"], [], [], [], [], ["2H"], ["2H"], [], [], [], [], [], []], moveCount: 1),
        // Test put waste into stock
        (gameRep: [[], ["KH", "QH"], [], [], [], [], [], [], [], [], [], [], []], moveCount: 1),
    ])
    func testNumberOfValidMoves(config: (gameRep: [[String]], moveCount: Int)) {
        let game = SolitaireGame.loadGame(from: config.gameRep)
        let validMoves = game.validMoves()
        #expect(validMoves.count == config.moveCount)
    }
    
    @Test("Test valid move #1")
    func testValidMoveOne() {
        let gameRep: [[String]] = [[], [], [], [], [], [], ["3S"], ["2H"], [], [], [], [], []]
        let game = SolitaireGame.loadGame(from: gameRep)
        let validMoves = game.validMoves()
        if case let .regular(card, source, dest) = validMoves[0] {
            #expect(card.suit == .hearts)
            #expect(card.rank == .two)
            
            #expect(source.id == .columnTwo)
            #expect(dest.id == .columnOne)
        }
    }

    @Test("Test valid move #2")
    func testValidMoveTwo() {
        let gameRep: [[String]] = [[], [], ["AH"], [], [], [], [], ["2H"], [], [], [], [], []]
        let game = SolitaireGame.loadGame(from: gameRep)
        let validMoves = game.validMoves()

        if case let .regular(card, source, dest) = validMoves[0] {
            #expect(card.suit == .hearts)
            #expect(card.rank == .two)
            
            #expect(source.id == .columnTwo)
            #expect(dest.id == .foundationOne)
        }
    }
}
