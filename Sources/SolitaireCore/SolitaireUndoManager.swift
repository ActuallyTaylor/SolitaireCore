//
//  UndoManager.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 6/27/25.
//

enum UndoPackage {
    case moveCards(cards: [PlayingCard], source: GamePileIndex, destination: GamePileIndex, scoreChange: ScoreInteger, negativeScoreChange: Bool)
    case drawStock(cards: [PlayingCard])
    case restock(scoreChange: ScoreInteger)
}

public enum UndoError: Error {
    case stackEmpty
    case noTarget
}

final class SolitaireUndoManager {
    private var stack: [UndoPackage] = []
    
    var target: SolitaireGame? = nil
    
    func registerUndo(package: UndoPackage) {
        stack.append(package)
    }
    
    func undo() throws(UndoError) {
        guard let packageToUndo = stack.last else { throw UndoError.stackEmpty }
        try undoPackage(package: packageToUndo)
        stack.removeLast()
        
        guard let target else { throw UndoError.noTarget }
        if target.config.undoAddsMove {
            target.addMoves(value: 1)
        } else {
            target.subtractMoves(value: 1)
        }
    }
    
    // We do not need to support redo... And I don't totally wanna figure it out right now so I won't implement it yet.
//    func redo() {
//        
//    }
    
    private func undoPackage(package: UndoPackage) throws(UndoError) {
        switch package {
        case .moveCards(let cards, let source, let destination, let scoreChange, let negativeScoreChange):
            undoMoveCardPackage(cards: cards, source: source, destination: destination, scoreChange: scoreChange, negativeScoreChange: negativeScoreChange)
        case .drawStock(let cards):
            try undoStockPackage(cards: cards)
        case .restock(let scoreChange):
            try undoRestockPackage(scoreChange: scoreChange)
        }
    }
    
    private func undoMoveCardPackage(cards: [PlayingCard], source: GamePileIndex, destination: GamePileIndex, scoreChange: ScoreInteger, negativeScoreChange: Bool) {
        guard let sourcePile = target?.pile(at: source) else { return }
        guard let destinationPile = target?.pile(at: destination) else { return }
        
        // If the card above the top card is visible, we do not want to set the visibility to false.
        if !(sourcePile.cardFromTop(offset: 2)?.isVisible ?? false) {
            sourcePile.top()?.isVisible = false
        }
        destinationPile.remove(cards: cards)
        sourcePile.add(cards: cards)

        if negativeScoreChange {
            target?.addScore(value: scoreChange)
        } else {
            target?.subtractScore(value: scoreChange)
        }
    }
    
    private func undoStockPackage(cards: [PlayingCard]) throws(UndoError) {
        guard let target else { throw UndoError.stackEmpty }
        // Access the waste and stock directly. Not the best but it reduces the data size for the UndoPackage
        target.waste().remove(cards: cards)
        target.stock().add(cards: cards)
        cards.forEach({$0.isVisible = false })

        target.subtractMoves(value: MoveInteger(cards.count))
    }
    
    private func undoRestockPackage(scoreChange: ScoreInteger) throws(UndoError) {
        guard let target else { throw UndoError.stackEmpty }
        
        target.swapPiles(target.waste(), target.stock())
        target.waste().cards.forEach({$0.isVisible = true})
        target.waste().reverse()
        target.subtractRestocks(value: 1)
        target.addScore(value: scoreChange) // Restocks are always negative so add it back
    }
}

extension SolitaireUndoManager: Copyable {
    func copy() -> SolitaireUndoManager {
        let newUndoManager = SolitaireUndoManager()
        newUndoManager.stack = stack
        return newUndoManager
    }
}
