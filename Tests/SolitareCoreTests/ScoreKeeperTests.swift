//
//  ScoreKeeperTests.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 8/7/25.
//

import Testing
@testable import SolitaireCore

struct ScoreKeeperTests {
    @Test("Test scoring a move to another pile", arguments: [
        // Simple move one card to another and check the standard move score.
        [[], [], [], [], [], [], ["3♥"], ["2♠"], [], [], [], [], []],
    ])
    func testMoveToAnotherPile(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        
        let cardToMove = columnTwo.top()!
        let index = columnTwo.cards.firstIndex(of: cardToMove) ?? 0

        let scoreKeeper = ScoreKeeper()
        let scoreChange = scoreKeeper.scoreRegularMove(card: cardToMove, source: columnTwo, destination: columnOne, cardIndex: index)
        #expect(scoreChange == ScoreEvent.moveToAnotherPile.scoreChange)
    }
    
    @Test("Test scoring a move to another pile", arguments: [
        // Uncover the 3 of spades to test the uncover card score
        [[], [], [], [], [], [], ["3♥"], ["2♠", "3♠"], [], [], [], [], []],
    ])
    func testUncoverCard(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let columnTwo = game.piles[GamePileIndex.columnTwo.rawValue]
        
        let cardToMove = columnTwo.top()!
        let index = columnTwo.cards.firstIndex(of: cardToMove) ?? 0

        print(cardToMove, index)
        let scoreKeeper = ScoreKeeper()
        var scoreChange = scoreKeeper.scoreRegularMove(card: cardToMove, source: columnTwo, destination: columnOne, cardIndex: index)
        
        // We need to subtract the score of a standard move
        scoreChange -= Int(ScoreEvent.moveToAnotherPile.scoreChange)
        
        #expect(scoreChange == ScoreEvent.uncoverCard.scoreChange)
    }

    @Test("Test scoring a move to another pile", arguments: [
        // Move the two of spades from the waste to column one
        [[], ["2♠"], [], [], [], [], ["3♥"], [], [], [], [], [], []],
        // Move the two of spades to the 3 of hearts
        [[], ["2♠", "4♥"], [], [], [], [], ["3♥"], [], [], [], [], [], []],

    ])
    func testMoveFromWaste(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let waste = game.piles[GamePileIndex.waste.rawValue]
        waste.cards.forEach({ $0.isVisible = true })
        
        let cardToMove = waste.top()!
        let index = waste.cards.firstIndex(of: cardToMove) ?? 0

        let scoreKeeper = ScoreKeeper()
        let scoreChange = scoreKeeper.scoreRegularMove(card: cardToMove, source: waste, destination: columnOne, cardIndex: index)
        
        #expect(scoreChange == ScoreEvent.moveFromWaste.scoreChange)
    }
    
    @Test("Test scoring a move to foundation scoring", arguments: [
        // Move the ace of hearts to the foundation
        [[], [], [], [], [], [], ["A♥"], [], [], [], [], [], []],
        // Move the two of hearts to the foundation, on top of an ace of hearts
        [[], [], ["A♥"], [], [], [], ["2♥"], [], [], [], [], [], []],
        
        // Score complete stacks
        [[], [], ["A♠", "2♠", "3♠", "4♠", "5♠", "6♠", "7♠", "8♠", "9♠", "10♠", "J♠", "Q♠"], [], [], [], ["K♠"], [], [], [], [], [], []],
        [[], [], ["A♦", "2♦", "3♦", "4♦", "5♦", "6♦", "7♦", "8♦", "9♦", "10♦", "J♦", "Q♦"], [], [], [], ["K♦"], [], [], [], [], [], []],
        [[], [], ["A♣", "2♣", "3♣", "4♣", "5♣", "6♣", "7♣", "8♣", "9♣", "10♣", "J♣", "Q♣"], [], [], [], ["K♣"], [], [], [], [], [], []],
        [[], [], ["A♥", "2♥", "3♥", "4♥", "5♥", "6♥", "7♥", "8♥", "9♥", "10♥", "J♥", "Q♥"], [], [], [], ["K♥"], [], [], [], [], [], []],
    ])
    func testMoveToFoundation(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let foundationOne = game.piles[GamePileIndex.foundationOne.rawValue]
        
        // Make sure the foundation cards are visible, since they will be in a real game
        foundationOne.cards.forEach({ $0.isVisible = true })
        
        let cardToMove = columnOne.top()!
        let index = columnOne.cards.firstIndex(of: cardToMove) ?? 0

        let scoreKeeper = ScoreKeeper()
        let scoreChange = scoreKeeper.scoreRegularMove(card: cardToMove, source: columnOne, destination: foundationOne, cardIndex: index)
        
        #expect(scoreChange == ScoreEvent.moveToFoundation.scoreChange)
    }
    
    @Test("Test scoring a move to foundation scoring", arguments: [
        // Move the ace of hearts to the foundation
        [[], [], [], [], [], [], ["A♥"], [], [], [], [], [], []],
        // Move the two of hearts to the foundation, on top of an ace of hearts
        [[], [], ["A♥"], [], [], [], ["2♥"], [], [], [], [], [], []],
        
        // Score complete stacks
        [[], [], ["A♠", "2♠", "3♠", "4♠", "5♠", "6♠", "7♠", "8♠", "9♠", "10♠", "J♠", "Q♠"], [], [], [], ["K♠"], [], [], [], [], [], []],
        [[], [], ["A♦", "2♦", "3♦", "4♦", "5♦", "6♦", "7♦", "8♦", "9♦", "10♦", "J♦", "Q♦"], [], [], [], ["K♦"], [], [], [], [], [], []],
        [[], [], ["A♣", "2♣", "3♣", "4♣", "5♣", "6♣", "7♣", "8♣", "9♣", "10♣", "J♣", "Q♣"], [], [], [], ["K♣"], [], [], [], [], [], []],
        [[], [], ["A♥", "2♥", "3♥", "4♥", "5♥", "6♥", "7♥", "8♥", "9♥", "10♥", "J♥", "Q♥"], [], [], [], ["K♥"], [], [], [], [], [], []],
    ])
    func testFoundationMaxCardScoring(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        let foundationOne = game.piles[GamePileIndex.foundationOne.rawValue]
        
        // Make sure the foundation cards are visible, since they will be in a real game
        foundationOne.cards.forEach({ $0.isVisible = true })
        
        let cardToMove = columnOne.top()!
        let index = columnOne.cards.firstIndex(of: cardToMove) ?? 0

        let scoreKeeper = ScoreKeeper()
        let scoreChange = scoreKeeper.scoreRegularMove(card: cardToMove, source: columnOne, destination: foundationOne, cardIndex: index)
        
        #expect(scoreChange == ScoreEvent.moveToFoundation.scoreChange)
    }



    @Test("Test scoring a move out of foundation", arguments: [
        // Move three of hearts out of foundation to column one
        [[], [], ["A♥", "2♥", "3♥"], [], [], [], ["4♠"], [], [], [], [], [], []],

    ])
    func testMoveOutOfFoundation(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let foundationOne = game.piles[GamePileIndex.foundationOne.rawValue]
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        
        // Column one cards should be visible so we can move cards on to them
        columnOne.cards.forEach({ $0.isVisible = true })

        // Make sure the foundation cards are visible, since they will be in a real game
        foundationOne.cards.forEach({ $0.isVisible = true })
        
        let cardToMove = foundationOne.top()!
        let index = foundationOne.cards.firstIndex(of: cardToMove) ?? 0

        let scoreKeeper = ScoreKeeper()
        let scoreChange = scoreKeeper.scoreRegularMove(card: cardToMove, source: foundationOne, destination: columnOne, cardIndex: index)
        
        #expect(scoreChange == -Int(ScoreEvent.moveAwayFromFoundation.scoreChange))
    }
    
    @Test("Test scoring a move out of foundation using game move function", arguments: [
        // Move three of hearts out of foundation to column one
        [[], [], ["A♥", "2♥", "3♥"], [], [], [], ["4♠"], [], [], [], [], [], []],
    ])
    func testMoveOutOfFoundationInGame(gameRep: [[String]]) {
        let game = SolitaireGame.loadGame(from: gameRep)
        let foundationOne = game.piles[GamePileIndex.foundationOne.rawValue]
        let columnOne = game.piles[GamePileIndex.columnOne.rawValue]
        
        // Column one cards should be visible so we can move cards on to them
        columnOne.cards.forEach({ $0.isVisible = true })

        // Make sure the foundation cards are visible, since they will be in a real game
        foundationOne.cards.forEach({ $0.isVisible = true })
        
        // Add score so we can see the subtraction
        let initialScore: ScoreInteger = 100
        game.addScore(value: initialScore)
        
        let cardToMove = foundationOne.top()!
        
        // This move is valid
        #expect(game.move(.regular(card: cardToMove, sourcePile: foundationOne, destinationPile: columnOne)))
        
        #expect(game.score == initialScore - ScoreEvent.moveAwayFromFoundation.scoreChange)
    }
    
    @Test("Test scoring a draw one restock")
    func testRestockDrawOne() {
        let scoreKeeper = ScoreKeeper()
        
        // Check to make sure 0 returns 0, since there have been no restocks
        #expect(0 == scoreKeeper.scoreRestock(restocks: 0, drawMode: .one))
        
        // The first restock costs no score
        #expect(0 == scoreKeeper.scoreRestock(restocks: 1, drawMode: .one))
        
        // The second restock costs score
        #expect(ScoreEvent.restockDrawOne.scoreChange == scoreKeeper.scoreRestock(restocks: 2, drawMode: .one))
    }
    
    @Test("Test scoring a draw three restock")
    func testRestockDrawThree() {
        let scoreKeeper = ScoreKeeper()
        
        // Make sure a 0 restocks is free, since there have been no restocks
        #expect(0 == scoreKeeper.scoreRestock(restocks: 0, drawMode: .three))

        // The first four restocks are free
        for n in 1...4 {
            #expect(0 == scoreKeeper.scoreRestock(restocks: RestockInteger(n), drawMode: .three))
        }
        
        // The fifth restock costs score
        #expect(ScoreEvent.restockDrawThree.scoreChange == scoreKeeper.scoreRestock(restocks: 5, drawMode: .three))
    }
}
