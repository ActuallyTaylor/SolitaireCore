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
    
    
    public func bestMove(in gameState: SolitaireGame) -> SolitaireMove? {
        // It is REALLY important to copy the game state. SolitaireGame is a class which is a reference type.
        // If we did not copy the state, we would edit the object coming in. This could be fixed in the future
        // by passing a game representation instead of an object.
        let gameState = gameState.copy()
        
        // Fetch the next all of the possible moves
        let validMoves = gameState.validMoves()
        
        var scoredMoves: [(UInt16, SolitaireMove)] = []
        
        // Score each of the moves by counting their score increase.
        for validMove in validMoves {
            let gameCopy = gameState.copy()
            gameCopy.move(validMove)
            scoredMoves.append((gameCopy.score, validMove))
        }

        /*
         Thoughts:
         At the moment i think the reference copying is not the best forward move. It copies the entire game state including undo managers and score keepers.
         I think this is going to require a restructure
         */
    }
    
    public static func nextMove(state game: SolitaireGame) -> SolitaireMove? {
        let game = game.copy()
        
        

        // for move in scoredMoves {
        //     switch move.1 {
        //     case .drawStock(_):
        //         print("Draw Stock move: \(move.0)")
        //     case .regular(let card, let sourcePile, let destinationPile):
        //         print("Card \(card.description) from \(sourcePile.description) to \(destinationPile.description): \(move.0)")
        //     case .reStock:
        //         print("Restock: \(move.0)")
        //     case .none:
        //         print("Failed none")
        //     }
        // }
        
        return scoredMoves.first?.1
    }
}


/*
 Thinking
 - Artificial player should be lazy solving.
 - Solving takes the most up to date game.
 - If that game state has already been explored, we can chuck all other game states not in its children.
 */
