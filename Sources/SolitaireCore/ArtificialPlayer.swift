//
//  ArtificialPlayer.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

// class ArtificalPlayer {
//     let game: SolitaireGame
//     
//     init(game: SolitaireGame) {
//         self.game = game
//     }
//     
//     func nextMove() -> SolitaireMove {
//         let validMoves = game.validMoves()
//         var scoredMoves: [(Int, SolitaireMove)] = []
//         
//         for validMove in validMoves {
//             let gameCopy = game.copy()
//             gameCopy.move(validMove)
//             scoredMoves.append((game.score, validMove))
//         }
//         
//         return .none
//     }
// }
