//
//  UndoManagerTests.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 7/31/25.
//

import Testing
@testable import SolitaireCore

struct UndoManagerTests {
    // MARK: Undo Tests
    @Test("Test undo basic move", arguments: [
        // Simple
        [[], [], [], [], [], [], ["3♠"], ["2♥"], [], [], [], [], []],
        
        // Stack
        [[], [], [], [], [], [], ["4♥"], ["3♠", "2♥"], [], [], [], [], []],
    ])
    func testUndoCardMovement(_ gameRep: [[String]]) throws {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let originalColumnOneCards = columnOne.cards.map({$0.copy()})

        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        let originalColumnTwoCards = columnTwo.cards.map({$0.copy()})
        
        let cardToMove = columnTwo.getCards().first!
        
        #expect(game.move(.regular(card: cardToMove, sourcePile: columnTwo, destinationPile: columnOne)))
        
        try game.undo()
        
        #expect(columnOne.cards == originalColumnOneCards)
        #expect(columnTwo.cards == originalColumnTwoCards)
    }
    
    @Test("Test multiple move undos", arguments: [
        // Simple
        [[], [], [], [], [], [], ["4♠"], ["3♥"], ["2♠"], [], [], [], []],
        
        // Stack
        [[], [], [], [], [], [], ["5♥"], ["4♠", "3♥"], ["2♠"], [], [], [], []],
    ])
    func testUndoMultipleMoves(_ gameRep: [[String]]) throws {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let originalColumnOneCards = columnOne.cards.map({$0.copy()})

        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        let originalColumnTwoCards = columnTwo.cards.map({$0.copy()})
        
        let columnThree = game.piles[GamePileIndex.columnThree.rawValue]
        let originalColumnThreeCards = columnThree.cards.map({$0.copy()})

        // Move one (Move column two to column one)
        let firstCardToMove = columnTwo.getCards().first!
        
        #expect(game.move(.regular(card: firstCardToMove, sourcePile: columnTwo, destinationPile: columnOne)))
        
        // Move two (Move column three to column one)
        let secondCardToMove = columnThree.getCards().first!
        
        #expect(game.move(.regular(card: secondCardToMove, sourcePile: columnThree, destinationPile: columnOne)))

        // Undo Move Two
        try game.undo()
        #expect(columnOne.cards == originalColumnOneCards + originalColumnTwoCards)
        #expect(columnTwo.cards == [])
        #expect(columnThree.cards == originalColumnThreeCards)
        

        // Undo Move One
        try game.undo()
        #expect(columnOne.cards == originalColumnOneCards)
        #expect(columnTwo.cards == originalColumnTwoCards)
        #expect(columnThree.cards == originalColumnThreeCards)
    }
    
    @Test("Test undos properly wiped", arguments: [
        // Simple
        [[], [], [], [], [], [], ["4♠"], ["3♥"], ["2♠"], [], [], [], []],
        
        // Stack
        [[], [], [], [], [], [], ["5♥"], ["4♠", "3♥"], ["2♠"], [], [], [], []],
    ])
    func testUndosWipedOnMove(_ gameRep: [[String]]) throws {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let originalColumnOneCards = columnOne.cards.map({$0.copy()})

        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        let originalColumnTwoCards = columnTwo.cards.map({$0.copy()})
        
        let columnThree = game.piles[GamePileIndex.columnThree.rawValue]
        let originalColumnThreeCards = columnThree.cards.map({$0.copy()})

        // Move one (Move column two to column one)
        let firstCardToMove = columnTwo.getCards().first!
        
        #expect(game.move(.regular(card: firstCardToMove, sourcePile: columnTwo, destinationPile: columnOne)))
        #expect(columnOne.cards == originalColumnOneCards + originalColumnTwoCards)
        #expect(columnTwo.cards == [])
        #expect(columnThree.cards == originalColumnThreeCards)


        // Undo Move One
        try game.undo()
        #expect(columnOne.cards == originalColumnOneCards)
        #expect(columnTwo.cards == originalColumnTwoCards)
        #expect(columnThree.cards == originalColumnThreeCards)

        // Move two (Move column three to column one)
        let secondCardToMove = columnThree.getCards().first!
        
        #expect(game.move(.regular(card: secondCardToMove, sourcePile: columnThree, destinationPile: columnTwo)))
        #expect(columnOne.cards == originalColumnOneCards)
        #expect(columnTwo.cards == originalColumnTwoCards + originalColumnThreeCards)
        #expect(columnThree.cards == [])

        try game.undo()
        #expect(columnOne.cards == originalColumnOneCards)
        #expect(columnTwo.cards == originalColumnTwoCards)
        #expect(columnThree.cards == originalColumnThreeCards)
    }
    
    @Test("Test undo draw from stock", arguments: [
        // Draw one card from stock into waste
        [["K♥"], [], [], [], [], [], [], [], [], [], [], [], []],
        [["K♥", "Q♥"], [], [], [], [], [], [], [], [], [], [], [], []],
    ])
    func testUndoDrawFromStock(gameRep: [[String]]) throws {
        let game = SolitaireGame.loadGame(from: gameRep)
        let stock = game.piles[GamePileIndex.stock.rawValue]
        let originalStockCards = stock.cards.map({$0.copy()})

        let waste = game.piles[GamePileIndex.waste.rawValue]
        let originalWasteCards = waste.cards.map({$0.copy()})

        #expect(game.move(.drawStock))
        
        try game.undo()
        
        #expect(stock.cards == originalStockCards)
        #expect(waste.cards == originalWasteCards)
    }
    
    @Test("Test restock", arguments: [
        // Restock one card into stock
        [[], ["K♥"], [], [], [], [], [], [], [], [], [], [], []],
        // Restock two cards into stock
        [[], ["Q♥", "K♥"], [], [], [], [], [], [], [], [], [], [], []]
    ])
    func testUndoRestock(gameRep: [[String]]) throws {
        let game = SolitaireGame.loadGame(from: gameRep)
        let stock = game.piles[GamePileIndex.stock.rawValue]

        let waste = game.piles[GamePileIndex.waste.rawValue]
        let originalWasteCards = waste.cards.map({$0.copy()})
        
        #expect(game.move(.reStock))
        
        try game.undo()
        
        #expect(stock.cards == [])
        #expect(waste.cards == originalWasteCards)
    }
}
