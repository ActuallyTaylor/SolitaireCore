//
//  ArtificalPlayerTests.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

 import Testing
 @testable import SolitaireCore

 struct ArtificialPlayerTests {
     @Test("Tests to make sure the artificial player moves black onto white and vice versa.", arguments: [
        [
            [], [],
            [], // Column One
            [], // Column Two
            [], // Column Three
            [], // Column Four
            ["KH"], [], [], [], [], [], []
        ],
    ])
     func testBasicMoves(gameRep: [[String]]) {
       let game = SolitaireGame.loadGame(from: gameRep)
       let nextMove = ArtificialPlayer.nextMove(game: game)

     }
     
      @Test("Test single move to win", arguments: [
          [
              [], [],
              ["AS", "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS"],
              ["AD", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD"],
              ["AC", "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC"],
              ["AH", "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH"],
              ["KH"], [], [], [], [], [], []
          ],
      ])
//      func testSingleMoveToWin(gameRep: [[String]]) {
//          let game = SolitaireGame.loadGame(from: gameRep)
//          let nextMove = ArtificialPlayer.nextMove(game: game)
//
//          if case .regular(let card, let pile, let destination) = nextMove {
//              #expect(card == .init(suit: .hearts, rank: .king))
//              #expect(destination.isFoundation)
//          }
//
// //         player.solve(game: game)
//      }

 }
