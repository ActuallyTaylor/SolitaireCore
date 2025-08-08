//
//  GameTests.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

import Testing
@testable import SolitaireCore

struct DeckSizeTests {
    @Test("Validate the right amount of cards are created")
    func validateDeckContents() {
        let game = SolitaireGame()
        let cards = game.piles.flatMap({$0.cards})
        
        #expect(cards.count == 52, "Not enough cards in deck.")
        
        // Check the colors
        let blackCards = cards.filter({$0.color == .black})
        #expect(blackCards.count == 26, "Not enough black cards.")
        
        let redCards = cards.filter({$0.color == .red})
        #expect(redCards.count == 26, "Not enough red cards.")
        
        // Check all of the suits
        for suit in Suit.allCases {
            let suitCards = cards.filter({$0.suit == suit})
            #expect(suitCards.count == 13, "\(suit) does not have the right amount of cards.")
        }
    }
    
    
    @Test("Validate empty piles at start of game", arguments: [
        GamePileIndex.foundationOne.rawValue,
        GamePileIndex.foundationTwo.rawValue,
        GamePileIndex.foundationThree.rawValue,
        GamePileIndex.foundationFour.rawValue,
        GamePileIndex.waste.rawValue
    ])
    func validateEmptyPiles(_ index: Int) {
        let game = SolitaireGame()
        let pile = game.piles[index]
        #expect(pile.isEmpty)
    }
    
    
    @Test("Validate that the stock has the right number of cards")
    func validateStockSize() async throws {
        let game = SolitaireGame()
        let pile = game.piles[GamePileIndex.stock.rawValue]
        #expect(pile.cards.count == 24)
    }


    @Test("Validate correct column counts")
    func validateColumnCounts() {
        let game = SolitaireGame()

        let startingColumnIndex = GamePileIndex.columnOne.rawValue
        let endingColumnIndex = GamePileIndex.columnSeven.rawValue
        
        var columnPointer = startingColumnIndex
        while columnPointer <= endingColumnIndex {
            let pile = game.piles[columnPointer]
            let expectedCards = (columnPointer - startingColumnIndex) + 1
            #expect(pile.cards.count == expectedCards)
            
            columnPointer += 1
        }
    }
}
