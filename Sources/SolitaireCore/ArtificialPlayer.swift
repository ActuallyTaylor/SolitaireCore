//
//  ArtificialPlayer.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

 class ArtificialPlayer {
     let game: SolitaireGame
     
     init(game: SolitaireGame) {
         self.game = game
     }
     
     func nextMove() -> SolitaireMove? {
         let validMoves = game.validMoves()
         var scoredMoves: [(UInt16, SolitaireMove)] = []
         
         for validMove in validMoves {
             let gameCopy = game.copy()
             gameCopy.move(validMove)
             scoredMoves.append((game.score, validMove))
         }
         
         scoredMoves.sort { $0.0 > $1.0 }

         return scoredMoves.first?.1
     }
 }
