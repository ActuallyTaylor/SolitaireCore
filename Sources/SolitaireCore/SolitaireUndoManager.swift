//
//  UndoManager.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 6/27/25.
//

enum UndoPackage {
    case moveCards(cards: [PlayingCard], source: GamePileIndex, destination: GamePileIndex, scoreChange: ScoreInteger)
    case drawStock(cards: [PlayingCard], scoreChange: ScoreInteger)
    case restock
}

public enum UndoError: Error {
    case stackEmpty
    case noTarget
}

class SolitaireUndoManager {
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
        case .moveCards(let cards, let source, let destination, let scoreChange):
            undoMoveCardPackage(cards: cards, source: source, destination: destination, scoreChange: scoreChange)
        case .drawStock(let cards, let scoreChange):
            try undoStockPackage(cards: cards, scoreChange: scoreChange)
        case .restock:
            try undoRestockPackage(package: package)
        }
    }
    
    private func undoMoveCardPackage(cards: [PlayingCard], source: GamePileIndex, destination: GamePileIndex, scoreChange: ScoreInteger) {
        guard let sourcePile = target?.pile(at: source) else { return }
        guard let destinationPile = target?.pile(at: destination) else { return }
        
        sourcePile.top()?.isVisible = false
        destinationPile.remove(cards: cards)
        sourcePile.add(cards: cards)

        target?.subtractScore(value: scoreChange)
    }
    
    private func undoStockPackage(cards: [PlayingCard], scoreChange: ScoreInteger) throws(UndoError) {
        guard let target else { throw UndoError.stackEmpty }
        // Access the waste and stock directly. Not the best but it reduces the data size for the UndoPackage
        target.stock().add(cards: cards)
        target.waste().remove(cards: cards)
        
        target.subtractScore(value: scoreChange)
    }
    
    private func undoRestockPackage(package: UndoPackage) throws(UndoError) {
        guard let target else { throw UndoError.stackEmpty }
        
        target.swapPiles(target.waste(), target.stock())
        target.waste().cards.forEach({$0.isVisible = true})
        target.waste().reverse()
        target.subtractRestocks(value: 1)
        target.subtractScore(value: 1)
    }
}
