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
    func testUndoCardMovement(_ gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let originalColumnOneCards = columnOne.cards.map({$0.copy()})

        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        let originalColumnTwoCards = columnTwo.cards.map({$0.copy()})
        
        let cardToMove = columnTwo.getCards().first!
        
        #expect(game.move(.regular(card: cardToMove, sourcePile: columnTwo, destinationPile: columnOne)))
        
        game.undo()
        
        #expect(columnOne.cards == originalColumnOneCards)
        #expect(columnTwo.cards == originalColumnTwoCards)
    }
    
    @Test("Test multiple move undos", arguments: [
        // Simple
        [[], [], [], [], [], [], ["4♠"], ["3♥"], ["2♠"], [], [], [], []],
        
        // Stack
        [[], [], [], [], [], [], ["5♥"], ["4♠", "3♥"], ["2♠"], [], [], [], []],
    ])
    func testMultipleMoveUndos(_ gameRep: [[String]]) {
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
        game.undo()
        #expect(columnOne.cards == originalColumnOneCards + originalColumnTwoCards)
        #expect(columnTwo.cards == [])
        #expect(columnThree.cards == originalColumnThreeCards)
        

        // Undo Move Three
        game.undo()
        #expect(columnOne.cards == originalColumnOneCards)
        #expect(columnTwo.cards == originalColumnTwoCards)
        #expect(columnThree.cards == originalColumnThreeCards)
    }

    
    @Test("Test undo draw from stock", arguments: [
        // Draw one card from stock into waste
        [["K♥"], [], [], [], [], [], [], [], [], [], [], [], []],
        [["K♥", "Q♥"], [], [], [], [], [], [], [], [], [], [], [], []],
    ])
    func testUndoDrawFromStock(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let stock = game.piles[GamePileIndex.stock.rawValue]
        let originalStockCards = stock.cards.map({$0.copy()})

        let waste = game.piles[GamePileIndex.waste.rawValue]
        let originalWasteCards = waste.cards.map({$0.copy()})

        #expect(game.move(.drawStock))
        
        game.undo()
        
        #expect(stock.cards == originalStockCards)
        #expect(waste.cards == originalWasteCards)
    }
    
    @Test("Test restock", arguments: [
        // Restock one card into stock
        [[], ["K♥"], [], [], [], [], [], [], [], [], [], [], []],
        // Restock two cards into stock
        [[], ["Q♥", "K♥"], [], [], [], [], [], [], [], [], [], [], []]
    ])
    func testUndoRestock(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let stock = game.piles[GamePileIndex.stock.rawValue]

        let waste = game.piles[GamePileIndex.waste.rawValue]
        let originalWasteCards = waste.cards.map({$0.copy()})
        
        #expect(game.move(.reStock))
        
        #expect(stock.cards == originalWasteCards.reversed())
        #expect(waste.cards == [])
    }
}
