//
//  MovementTests.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

import Testing
@testable import SolitaireCore

struct MovementTests {    
    // Columns 1 & 2 are populated with a alternating colors. This tests moving a Red -> Black & Black -> Red
    @Test("Test moving a single card onto aother card", arguments: [
        // Spades & Hearts
        [[], [], [], [], [], [], ["3♠"], ["2♥"], [], [], [], [], []],
        [[], [], [], [], [], [], ["3♥"], ["2♠"], [], [], [], [], []],
        
        // Spades & Diamonds
        [[], [], [], [], [], [], ["3♠"], ["2♦"], [], [], [], [], []],
        [[], [], [], [], [], [], ["3♦"], ["2♠"], [], [], [], [], []],
        
        // Clubs & Hearts
        [[], [], [], [], [], [], ["3♣"], ["2♥"], [], [], [], [], []],
        [[], [], [], [], [], [], ["3♥"], ["2♣"], [], [], [], [], []],
        
        // Clubs & Diamonds
        [[], [], [], [], [], [], ["3♣"], ["2♦"], [], [], [], [], []],
        [[], [], [], [], [], [], ["3♦"], ["2♣"], [], [], [], [], []],
    ])
    func testCardMovement(_ gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        
        let cardToMove = columnTwo.getCards().first!
        
        #expect(game.move(.regular(card: cardToMove, sourcePile: columnTwo, destinationPile: columnOne)))
    }
    
    // Columns 1 & 2 are populated with a alternating colors. This tests moving a Red -> Black & Black -> Red
    @Test("Test moving a single card onto aother card", arguments: [
        [[], [], ["A♥"], [], [], [], ["3♥"], [], [], [], [], [], []],
        [[], [], ["A♥"], [], [], [], ["2♠"], [], [], [], [], [], []],
    ])
    func testInvalidCardMovement(_ gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let foundationOne = game.piles[GamePileIndex.foundationOne.rawValue]
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        
        let cardToMove = columnOne.getCards().first!
        
        #expect(!game.move(.regular(card: cardToMove, sourcePile: columnOne, destinationPile: foundationOne)))
    }


    @Test("Test moving two cards at a time", arguments: [
        // Column 1 is populated with two cards of alternating suits. Column 2 is populated with an alternate suit 1 higher rank than the top card in column 1.
        [[], [], [], [], [], [], ["3♥", "2♠"], ["4♠"], [], [], [], [], []],
        [[], [], [], [], [], [], ["3♠", "2♥"], ["4♥"], [], [], [], [], []]
    ])
    func testMoveMultipleCardsValid(_ gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        
        let threeOfHearts = columnOne.getCards().first!
        
        #expect(game.move(.regular(card: threeOfHearts, sourcePile: columnOne, destinationPile: columnTwo)))
        #expect(columnTwo.getCards().count == 3)
    }

    @Test("Test moving two cards onto an invalid position", arguments: [
        // Tests moving a card onto another that is the same color (fails)
        [[], [], [], [], [], [], ["3♥", "2♠"], ["4♥"], [], [], [], [], []],
        // Tests moving a card onto a card not one rank above
        [[], [], [], [], [], [], ["3♥", "2♠"], ["5♠"], [], [], [], [], []]
    ])
    func testMoveMultipleCardsInvalid( gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        
        let threeOfHearts = columnOne.getCards().first!
        
        #expect(!game.move(.regular(card: threeOfHearts, sourcePile: columnOne, destinationPile: columnTwo)))
    }
}
