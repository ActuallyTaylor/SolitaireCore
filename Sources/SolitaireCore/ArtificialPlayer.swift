//
//  ArtificialPlayer.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

//struct Node {
//    let game: SolitaireGame
//    let moveMade: SolitaireMove
//    var score: ScoreInteger = 0
//    var moves: MoveInteger = 0
//
//    var children: [Node] = []
//
//    init(game: SolitaireGame, move moveMade: SolitaireMove, children: [Node] = []) {
//        self.game = game
//        self.moveMade = moveMade
//        self.children = children
//    }
//
//    mutating func getChildren() -> [Node] {
//        // Only calculate children once
//        guard children.isEmpty else { return children }
//        let validMoves = game.validMoves()
//
//        for validMove in validMoves {
//            let gameCopy = game.copy()
//            gameCopy.move(validMove)
//            print("Found child \(game.score) \(game.moves) is solved:\(game.isSolved)")
//            children.append(Node(game: gameCopy, move: validMove))
//        }
//
//        return children
//    }
//}

public class ArtificialPlayer {
//    var topOfTree: Node?
    // var game: SolitaireGame
//
    // public init(game: SolitaireGame) {
    //     self.game = game
    // }

//    func solve(game: SolitaireGame) {
//        let node = Node(game: game, move: .none)
//
//    }

//    func solve(node: Node) {
////        var scoredMoves: [(UInt16, SolitaireMove)] = []
//        var visitedNode: [Node] = []
//        var toVisitNodes: [Node] = [node]
//
//        while !toVisitNodes.isEmpty {
//            // Should never be hit, but safer than !
//            guard var node = toVisitNodes.popLast() else { break }
//            let children = node.getChildren()
//
//            toVisitNodes.append(contentsOf: children)
//            visitedNode.append(node)
//        }
//    }

    public static func nextMove(game: SolitaireGame) -> SolitaireMove? {
        let game = game.copy()

        /*
        Valid moves are a mess, scoring is incorrect
        Undo randomly changes the card visibility so that needs to be solved.
        */
        let validMoves = game.validMoves()
       .filter { move in
           switch move {
           case .regular(_, let sourcePile, let destinationPile):
               // Filter all moves that are not moves to the foundation
               if sourcePile.isColumn && destinationPile.isFoundation {
                   return true
               }

               return false
           case .reStock:
               return false
           case .drawStock(_):
               return false
           case .none:
               return false
           }
       }
        var scoredMoves: [(UInt16, SolitaireMove)] = []

        for validMove in validMoves {
            let gameCopy = game.copy()
            gameCopy.move(validMove)
            scoredMoves.append((gameCopy.score, validMove))
        }

        scoredMoves.sort(by: {$0.0 > $1.0})

        for move in scoredMoves {
            print("Score: \(move.0) \(move.1)")
        }

        return scoredMoves.first?.1
    }
}


/*
 Thinking
 - Artificial player should be lazy solving.
 - Solving takes the most up to date game.
 - If that game state has already been explored, we can chuck all other game states not in its children.
 */
