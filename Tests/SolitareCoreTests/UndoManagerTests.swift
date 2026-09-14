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
    @Test("Test undo basic move by moving column two onto column 1. ", arguments: [
        // Simple, move a 2 of hearts onto a 3 of spades.
        [[], [], [], [], [], [], ["3SV"], ["2HV"], [], [], [], [], []],

        // Stack, Move a stack under a 3 of spades onto a 4 of hearts.
        [[], [], [], [], [], [], ["4HV"], ["3SV", "2HV"], [], [], [], [], []],
        
        // Stack with one bottom invisible, We want to make sure the visibility of cards is preserved despite this not being a legal move.
        [[], [], [], [], [], [], ["5SV"], ["4H", "3SV", "2HV"], [], [], [], [], []],
    ])
    func testUndoCardMovement(_ gameRep: [[String]]) throws {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let originalColumnOneCards = columnOne.cards.map({$0.copy()})

        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
                
        let originalColumnTwoCards = columnTwo.cards.map({$0.copy()})

        let columnTwoCard = columnTwo.getCards().first!

        print(columnOne.cards, columnTwo.cards)

        #expect(game.move(.regular(card: columnTwoCard, sourcePile: columnTwo, destinationPile: columnOne)))

        print(columnOne.cards, columnTwo.cards)
        try game.undo()
        print(columnOne.cards, columnTwo.cards)

        #expect(columnOne.cards == originalColumnOneCards)
        
        for (card, originalCard) in zip(columnOne.cards, originalColumnOneCards) {
            #expect(card.isVisible == originalCard.isVisible)
        }
        
        #expect(columnTwo.cards == originalColumnTwoCards)
        
        for (card, originalCard) in zip(columnTwo.cards, originalColumnTwoCards) {
            #expect(card.isVisible == originalCard.isVisible)
        }
    }

    @Test("Test multiple move undos", arguments: [
        // Simple
        [[], [], [], [], [], [], ["4S"], ["3H"], ["2S"], [], [], [], []],

        // Stack
        [[], [], [], [], [], [], ["5H"], ["4S", "3H"], ["2S"], [], [], [], []],
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
        [[], [], [], [], [], [], ["4S"], ["3H"], ["2S"], [], [], [], []],

        // Stack
        [[], [], [], [], [], [], ["5H"], ["4S", "3H"], ["2S"], [], [], [], []],
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
        [["KH"], [], [], [], [], [], [], [], [], [], [], [], []],
        [["KH", "QH"], [], [], [], [], [], [], [], [], [], [], [], []],
    ])
    func testUndoDrawFromStock(gameRep: [[String]]) throws {
        let game = SolitaireGame.loadGame(from: gameRep)
        let stock = game.piles[GamePileIndex.stock.rawValue]
        let originalStockCards = stock.cards.map({$0.copy()})

        let waste = game.piles[GamePileIndex.waste.rawValue]
        let originalWasteCards = waste.cards.map({$0.copy()})

        #expect(game.move(.drawStock(drawMode: .one)))

        try game.undo()

        #expect(stock.cards == originalStockCards)
        #expect(waste.cards == originalWasteCards)

        for card in waste.getCards() {
            #expect(card.isVisible, "Card should be visible in the waste.")
        }
    }

    @Test("Validate undo does not break card visibility")
    func testUndoDoesNotBreakVisibility() throws {
        let gameRep = [
            ["QH", "3S", "5S"], [ ],
            [], [], [], [],
            ["KS"], [], [], [], [], [], []
            // , "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS"
        ]

        let game = SolitaireGame.loadGame(from: gameRep)

        // Setup the bug, we need to draw cards in the stock.
        #expect(game.move(.drawStock(drawMode: .one)))
        #expect(game.move(.drawStock(drawMode: .one)))
        #expect(game.move(.drawStock(drawMode: .one)))

        // Make sure we have three cards in the waste
        #expect(game.pile(at: .waste).cards.count == 3)

        guard let queenOfHearts = game.waste().top() else { #expect(false); return; }

        #expect(queenOfHearts == PlayingCard(suit: .hearts, rank: .queen, visible: true))

        // Move the third waste card into a column
        #expect(game.move(.regular(card: queenOfHearts, sourcePile: game.waste(), destinationPile: game.column(at: 0))))

        // All three cards we drew should be in the waste.
        #expect(game.pile(at: .waste).cards.count == 2)

        try game.undo()

        // We should still have a king in column one
        #expect(game.pile(at: .columnOne).cards.count == 1)

        // All three cards we drew should be in the waste.
        #expect(game.pile(at: .waste).cards.count == 3)

        // All of the cards in the waste should be visible.
        // The bug happens here! One of these cards will be invisible
        for card in game.pile(at: .waste).getCards() {
            #expect(card.isVisible)
        }
    }

    @Test("Test restock", arguments: [
        // Restock one card into stock
        [[], ["KH"], [], [], [], [], [], [], [], [], [], [], []],
        // Restock two cards into stock
        [[], ["QH", "KH"], [], [], [], [], [], [], [], [], [], [], []]
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
