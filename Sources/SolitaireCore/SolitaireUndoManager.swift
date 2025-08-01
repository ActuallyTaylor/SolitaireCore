//
//  UndoManager.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 6/27/25.
//

// or actor?
class SolitaireUndoManager {
    private var stack: [SolitaireMove] = []
    private var pointer = 0

    var target: SolitaireGame? = nil

    @discardableResult
    func undo() -> Bool {
        guard  pointer < stack.count && pointer >= 0 else { return false }
//        let moveToUndo = stack[pointer]


        return true
    }

    // We do not need to support redo... And I don't totally wanna figure it out right now so I won't implement it yet.
    @discardableResult
    func redo() -> Bool {
        return false
    }

    func addMove(_ move: SolitaireMove){
        stack.append(move)
    }

//    func reverseMove(move: SolitaireMove) {
//        switch move {
//        case .drawStock:
//            break
//        case .reStock:
//            break
//        case .regular(let card, let sourcePile, let destinationPile):
//            break
//        case .none:
//            break
//        }
//    }


    // func reverseStock() {


/*
guard let topOfStock = stock().pop() else { return false }
let originalCardState = topOfStock.copy()
waste().addCard(topOfStock)
topOfStock.isVisible = true

moves += 1

undoManager.registerUndo(withTarget: self) { object in
    object.stock().addCard(originalCardState)
    object.waste().remove(card: originalCardState)

    if object.config.undoAddsMove {
        object.moves += 1
    } else {
        object.moves -= 1
    }
}
*/
    // }
}

/*
MOVE
undoManager.registerUndo(withTarget: self) { object in
   destination.remove(cards: originalCardstoMove)
   pile.addCards(originalCardstoMove)

   if index >= 1 {
       pile.cards[index - 1].isVisible = false
   }

   if object.config.undoAddsMove {
       object.moves += 1
   } else {
       object.moves -= 1
   }

   object.score -= scoreChange
}

STOCK
guard let topOfStock = stock().pop() else { return false }
let originalCardState = topOfStock.copy()
waste().addCard(topOfStock)
topOfStock.isVisible = true

moves += 1

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

class EmbeddedUndoManager<TargetType: AnyObject> {
    typealias Event = (handler: Handler, target: TargetType)
    typealias Handler = (TargetType) -> Void
    var stack: [Event] = []
    var pointer = 0

    init() {

    }

    @discardableResult
    func undo() -> Bool {
        print("Undoing \(pointer), \(stack.count)")
        guard  pointer < stack.count && pointer >= 0 else { return false }
        print("Undoing")
        let eventToUndo = stack[pointer]
        eventToUndo.handler(eventToUndo.target)
        pointer -= 1

        return true
    }

    // We do not need to support redo... And I don't totally wanna figure it out right now so I won't implement it yet.
    @discardableResult
    func redo() -> Bool {
        // guard stack.count < pointer && pointer >= 0 else { return }
        // guard let eventToUndo = stack[pointer] else { return false }
        // eventToUndo.handler(eventToUndo.target)
        // pointer -= 1
        return false
    }

    func registerUndo(withTarget target: TargetType, handler: @escaping (TargetType) -> Void) {
        stack.append((handler, target))
        pointer = stack.count - 1
    }
}
