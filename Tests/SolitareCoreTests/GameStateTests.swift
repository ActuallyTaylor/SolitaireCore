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
            ["A♠", "2♠", "3♠", "4♠", "5♠", "6♠", "7♠", "8♠", "9♠", "10♠", "J♠", "Q♠", "K♠"],
            ["A♦", "2♦", "3♦", "4♦", "5♦", "6♦", "7♦", "8♦", "9♦", "10♦", "J♦", "Q♦", "K♦"],
            ["A♣", "2♣", "3♣", "4♣", "5♣", "6♣", "7♣", "8♣", "9♣", "10♣", "J♣", "Q♣", "K♣"],
            ["A♥", "2♥", "3♥", "4♥", "5♥", "6♥", "7♥", "8♥", "9♥", "10♥", "J♥", "Q♥", "K♥"],
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
            ["A♠", "2♠", "3♠", "4♠", "5♠", "6♠", "7♠", "8♠", "9♠", "10♠", "J♠", "Q♠", "K♠"],
            ["A♦", "2♦", "3♦", "4♦", "5♦", "6♦", "7♦", "8♦", "9♦", "10♦", "J♦", "Q♦", "K♦"],
            ["A♣", "2♣", "3♣", "4♣", "5♣", "6♣", "7♣", "8♣", "9♣", "10♣", "J♣", "Q♣", "K♣"],
            ["A♥", "2♥", "3♥", "4♥", "5♥", "6♥", "7♥", "8♥", "9♥"],
            ["10♥", "J♥", "Q♥", "K♥"], [], [], [], [], [], []
        ],
        [
            // Swap some of the suits around
            [], [],
            ["A♠", "2♦", "3♠", "4♠", "5♠", "6♠", "7♠", "8♠", "9♠", "10♠", "J♠", "Q♠", "K♠"],
            ["A♦", "2♠", "3♦", "4♦", "5♦", "6♦", "7♦", "8♦", "9♦", "10♦", "J♦", "Q♦", "K♦"],
            ["A♣", "2♥", "3♣", "4♣", "5♣", "6♣", "7♣", "8♣", "9♣", "10♣", "J♣", "Q♣", "K♣"],
            ["A♥", "2♣", "3♥", "4♥", "5♥", "6♥", "7♥", "8♥", "9♥", "10♥", "J♥", "Q♥", "K♥"],
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
        (gameRep: [[], [], [], [], [], [], ["3♠"], ["2♥"], [], [], [], [], []], moveCount: 1),
        // One destination (Black) and two possible moves (Red)
        (gameRep: [[], [], [], [], [], [], ["3♠"], ["2♥"], [], ["2♦"], [], [], []], moveCount: 2),
        // Two black destinations, with two red cards. Four possible moves
        (gameRep: [[], [], [], [], [], [], ["3♠"], ["2♥"], ["3♣"], ["2♦"], [], [], []], moveCount: 4),
        // One move into foundation
        (gameRep: [[], [], ["A♥"], [], [], [], [], ["2♥"], [], [], [], [], []], moveCount: 1),
        // Two possible foundation moves
        (gameRep: [[], [], ["2♥"], ["J♣"], [], [], [], ["3♥"], ["Q♣"], [], [], [], []], moveCount: 2),
        // Move ace into any of the four foundations
        (gameRep: [[], [], [], [], [], [], [], ["A♥"], [], [], [], [], []], moveCount: 4),
        // Move king into any of the six other foundations
        (gameRep: [[], [], [], [], [], [], [], ["K♥"], [], [], [], [], []], moveCount: 6),
        // Move king from hand to any of the seven foundation + restock
        (gameRep: [[], ["K♥"], [], [], [], [], [], [], [], [], [], [], []], moveCount: 8),
        // Test draw card from stock
        (gameRep: [["Q♥", "K♥"], [], [], [], [], ["2♥"], ["2♥"], [], [], [], [], [], []], moveCount: 1),
        // Test put waste into stock
        (gameRep: [[], ["K♥", "Q♥"], [], [], [], [], [], [], [], [], [], [], []], moveCount: 1),
    ])
    func testNumberOfValidMoves(config: (gameRep: [[String]], moveCount: Int)) {
        let game = SolitaireGame.loadGame(from: config.gameRep)
        let validMoves = game.validMoves()
        #expect(validMoves.count == config.moveCount)
    }
    
    @Test("Test valid move #1")
    func testValidMoveOne() {
        let gameRep: [[String]] = [[], [], [], [], [], [], ["3♠"], ["2♥"], [], [], [], [], []]
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
        let gameRep: [[String]] = [[], [], ["A♥"], [], [], [], [], ["2♥"], [], [], [], [], []]
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
