//
//  ArtificalPlayerTests.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

 import Testing
 @testable import SolitaireCore

 struct ArtificialPlayerTests {
     let startingGame: [[String]] = [
         // Stock
         ["6♣", "9♦", "3♣", "J♠", "2♠", "4♣", "K♦", "Q♣", "4♥", "7♦", "A♠", "J♥", "5♠", "J♣", "A♦", "Q♠", "7♣", "2♦", "4♠", "8♣", "10♦", "10♥", "7♥", "8♠"],
         // Waste
         [],

         // Foundation 1-4
         [],
         [],
         [],
         [],

         // Column 1-7
         ["3♠"],
         ["A♣", "3♥"],
         ["6♥", "9♣", "4♦"],
         ["8♥", "J♦", "K♣", "2♣"],
         ["7♠", "6♠", "9♠", "3♦", "10♣"],
         ["2♥", "8♦", "K♠", "10♠", "6♦", "K♥"],
         ["5♥", "9♥", "5♣", "Q♥", "A♥", "5♦", "Q♦"]
     ]

     @Test func createGame() async throws {
         // Write your test here and use APIs like `#expect(...)` to check expected conditions.
         let game = SolitaireGame.loadGame(from: startingGame)
         let player = ArtificialPlayer(game: game)

         let nextMove = player.nextMove()
         print(nextMove)
         
//         player.allValidMoves()
     }
 }
