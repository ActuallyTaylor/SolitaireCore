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

class SolitaireUndoManager {
    private var stack: [UndoPackage] = []
    private var pointer = -1
    
    var target: SolitaireGame? = nil
    
    func registerUndo(package: UndoPackage) {
        stack.append(package)
        pointer += 1
    }
    
    func undo() {
        guard  pointer < stack.count && pointer >= 0 else { return }
        let packageToUndo = stack[pointer]
        undoPackage(package: packageToUndo)
        pointer -= 1
        
        guard let target else { print("No target set"); return }
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
    
    private func undoPackage(package: UndoPackage) {
        switch package {
        case .moveCards(let cards, let source, let destination, let scoreChange):
            undoMoveCardPackage(cards: cards, source: source, destination: destination, scoreChange: scoreChange)
        case .drawStock(let card, let scoreChange):
            undoStockPackage(card: card, scoreChange: scoreChange)
        case .restock:
            undoRestockPackage(package: package)
        }
    }
    
    private func undoMoveCardPackage(cards: [PlayingCard], source: Pile, destination: Pile, scoreChange: Int) {
        source.top()?.isVisible = false
        destination.remove(cards: cards)
        source.add(cards: cards)

        target?.score -= scoreChange
    }
    
    private func undoStockPackage(card: PlayingCard, scoreChange: Int) {
        guard let target else { print("No target set"); return }
        // Access the waste and stock directly. Not the best but it reduces the data size for the UndoPackage
        target.stock().add(card: card)
        target.waste().remove(card: card)
        
        target.score -= scoreChange
    }
    
    private func undoRestockPackage(package: UndoPackage) {
        guard let target else { print("No target set"); return }
        
        target.swapPiles(target.waste(), target.stock())
        target.waste().cards.forEach({$0.isVisible = true})
        target.waste().reverse()
        target.restocks -= 1
        target.score -= 1
    }
}
/*
STOCK
undoManager.registerUndo(withTarget: self) { object in
    object.stock().addCard(originalCardState)
    object.waste().remove(card: originalCardState)

    if object.config.undoAddsMove {
        object.moves += 1
    } else {
        object.moves -= 1
    }
}


WASTE
undoManager.registerUndo(withTarget: self) { object in
    object.swapPiles(object.waste(), object.stock())
    object.waste().cards.forEach({$0.isVisible = true})
    object.waste().reverse()
    object.restocks -= 1
    object.score -= scoreChange

    if object.config.undoAddsMove {
        object.moves += 1
    } else {
        object.moves -= 1
    }
}
*/
