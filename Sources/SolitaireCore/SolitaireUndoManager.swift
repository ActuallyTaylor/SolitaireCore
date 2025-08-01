//
//  UndoManager.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 6/27/25.
//

enum UndoPackage {
    case moveCards(cards: [PlayingCard], source: Pile, destination: Pile, scoreChange: Int)
    case drawStock(card: PlayingCard, scoreChange: Int)
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
            target.moves += 1
        } else {
            target.moves -= 1
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
        case .drawStock(let card, let scoreChange):
            try undoStockPackage(card: card, scoreChange: scoreChange)
        case .restock:
            try undoRestockPackage(package: package)
        }
    }
    
    private func undoMoveCardPackage(cards: [PlayingCard], source: Pile, destination: Pile, scoreChange: Int) {
        source.top()?.isVisible = false
        destination.remove(cards: cards)
        source.add(cards: cards)

        target?.score -= scoreChange
    }
    
    private func undoStockPackage(card: PlayingCard, scoreChange: Int) throws(UndoError) {
        guard let target else { throw UndoError.stackEmpty }
        // Access the waste and stock directly. Not the best but it reduces the data size for the UndoPackage
        target.stock().add(card: card)
        target.waste().remove(card: card)
        
        target.score -= scoreChange
    }
    
    private func undoRestockPackage(package: UndoPackage) throws(UndoError) {
        guard let target else { throw UndoError.stackEmpty }
        
        target.swapPiles(target.waste(), target.stock())
        target.waste().cards.forEach({$0.isVisible = true})
        target.waste().reverse()
        target.restocks -= 1
        target.score -= 1
    }
}
