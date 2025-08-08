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
    func testCardMovement(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        
        let cardToMove = columnTwo.top()!
        
        #expect(game.move(.regular(card: cardToMove, sourcePile: columnTwo, destinationPile: columnOne)))
    }
    
    // Columns 1 & 2 are populated with a alternating colors. This tests moving a Red -> Black & Black -> Red
    @Test("Test moving a single card onto aother card", arguments: [
        [[], [], ["A♥"], [], [], [], ["3♥"], [], [], [], [], [], []],
        [[], [], ["A♥"], [], [], [], ["2♠"], [], [], [], [], [], []],
    ])
    func testInvalidCardMovement(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let foundationOne = game.piles[GamePileIndex.foundationOne.rawValue]
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        
        let cardToMove = columnOne.top()!
        
        #expect(!game.move(.regular(card: cardToMove, sourcePile: columnOne, destinationPile: foundationOne)))
    }


    @Test("Test moving two cards at a time", arguments: [
        // Column 1 is populated with two cards of alternating suits. Column 2 is populated with an alternate suit 1 higher rank than the top card in column 1.
        [[], [], [], [], [], [], ["3♥", "2♠"], ["4♠"], [], [], [], [], []],
        [[], [], [], [], [], [], ["3♠", "2♥"], ["4♥"], [], [], [], [], []]
    ])
    func testMoveMultipleCardsValid(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        
        let bottomCard = columnOne.bottom()!
        
        #expect(game.move(.regular(card: bottomCard, sourcePile: columnOne, destinationPile: columnTwo)))
        #expect(columnTwo.getCards().count == 3)
    }

    @Test("Test moving two cards onto an invalid position", arguments: [
        // Tests moving a card onto another that is the same color (fails)
        [[], [], [], [], [], [], ["3♥", "2♠"], ["4♥"], [], [], [], [], []],
        // Tests moving a card onto a card not one rank above
        [[], [], [], [], [], [], ["3♥", "2♠"], ["5♠"], [], [], [], [], []]
    ])
    func testMoveMultipleCardsInvalid(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        
        let columnOneOriginalCardCount = columnOne.cards.count
        
        let bottomCard = columnOne.bottom()!
        
        #expect(!game.move(.regular(card: bottomCard, sourcePile: columnOne, destinationPile: columnTwo)))
        #expect(columnOne.getCards().count == columnOneOriginalCardCount)
    }
    
    @Test("Test picking up cards", arguments: [
        // Tests moving a card onto another that is the same color (fails)
        [[], [], [], [], [], [], ["3♥", "2♠"], [], [], [], [], [], []],
    ])
    func testPickUpCardsValid(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        
        let topCard = columnOne.top()!
        topCard.isVisible = true
        
        #expect(game.canSelectCardInPile(card: topCard, pile: columnOne))
        
        let bottomCard = columnOne.bottom()!
        bottomCard.isVisible = true

        #expect(game.canSelectCardInPile(card: bottomCard, pile: columnOne))
    }
    
    @Test("Test picking up cards fails because it is picking up an invisible card", arguments: [
        // Tests moving a card onto another that is the same color (fails)
        [[], [], [], [], [], [], ["3♥", "2♠"], [], [], [], [], [], []],
    ])
    func testPickUpCardsInvalidBecauseInvisible(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        
        let topCard = columnOne.top()!
        topCard.isVisible = true
        
        #expect(game.canSelectCardInPile(card: topCard, pile: columnOne))
        
        let bottomCard = columnOne.bottom()!
        bottomCard.isVisible = false

        #expect(!game.canSelectCardInPile(card: bottomCard, pile: columnOne))
    }

    @Test("Test draw from stock", arguments: [
        // Draw one card from stock into waste
        [["K♥"], [], [], [], [], [], [], [], [], [], [], [], []],
        [["K♥", "Q♥"], [], [], [], [], [], [], [], [], [], [], [], []],
    ])
    func testDrawFromStockMove(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let stock = game.piles[GamePileIndex.stock.rawValue]
        let originalStockCount = stock.cards.count
        let waste = game.piles[GamePileIndex.waste.rawValue]

        #expect(game.move(.drawStock(drawMode: .one)))
        #expect(stock.getCards().count == originalStockCount - 1)
        #expect(waste.getCards().count == 1)
    }

    @Test("Test restock", arguments: [
        // Restock one card into stock
        [[], ["K♥"], [], [], [], [], [], [], [], [], [], [], []],
        // Restock two cards into stock
        [[], ["Q♥", "K♥"], [], [], [], [], [], [], [], [], [], [], []]
    ])
    func testRestockMove(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let stock = game.piles[GamePileIndex.stock.rawValue]
        let waste = game.piles[GamePileIndex.waste.rawValue]
        let originalWasteCount = waste.cards.count
        let originalWasteCards = waste.cards.map({$0.copy()})
        
        #expect(game.move(.reStock))
        #expect(stock.getCards().count == originalWasteCount)
        #expect(waste.getCards().count == 0)
        
        // Make sure that the cards went back into the stock reversed
        #expect(stock.getCards() == originalWasteCards.reversed())
    }

    @Test("Test draw from stock shortcut function")
    func testDrawFromStockShortcutFunction() {
        let gameRep: [[String]] = [["K♥"], [], [], [], [], [], [], [], [], [], [], [], []]
        let game = SolitaireGame.loadGame(from: gameRep)
        
        let stock = game.piles[GamePileIndex.stock.rawValue]
        let waste = game.piles[GamePileIndex.waste.rawValue]

        // First call should draw from stock -> waste
        game.drawFromStock()
        #expect(stock.getCards().count == 0)
        #expect(waste.getCards().count == 1)
        
        // Second call should resttock
        game.drawFromStock()
        #expect(stock.getCards().count == 1)
        #expect(waste.getCards().count == 0)
    }
}
