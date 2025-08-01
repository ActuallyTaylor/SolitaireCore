//
//  ObservableSolitaireGame.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 6/27/25.
//

/*
 //
 //  SolitaireGame.swift
 //  solitaire
 //
 //  Created by Taylor Lineman on 4/15/25.
 //

 import SwiftUI
 import os

 struct GameConfiguration {
     let canMoveFromWasteToFoundation: Bool
     let undoAddsMove: Bool
 }

 @Observable
 public final class SolitaireGame {
     private let undoManager: UndoManager = UndoManager()
     private let config: GameConfiguration = .init(
         canMoveFromWasteToFoundation: true,
         undoAddsMove: true
     )
     private let signposter = OSSignposter()
     
     // Used to track what moves into the foundation have been scored, and not re-score them
     private var highestScoredFoundationRank: [GamePileIndex: Rank?] = [
         .foundationOne: .none,
         .foundationTwo: .none,
         .foundationThree: .none,
         .foundationFour: .none
     ]
     
     public private(set) var restocks: Int = 0
     public private(set) var moves: Int = 0
     
     // Used to cap score at 0
     private var _score: Int = 0
     @ObservationIgnored private(set) var score: Int {
         get { _score }
         set { _score = max(0, newValue) }
     }
     
     private(set) var piles: [Pile] = []
     
     static func loadGame(from stringRep: [[String]]) -> SolitaireGame {
         var piles: [Pile] = []
         
         for index in GamePileIndex.allCases {
             let stringCards = stringRep[index.rawValue]
             let cards = stringCards.compactMap({PlayingCard(string: $0)})
             assert(cards.count == stringCards.count, "Failed to load card in \(stringCards)")
             
             piles.append(Pile(id: index, cards: cards))
         }
         
         piles.forEach({ $0.top()?.isVisible = true })
         
         return SolitaireGame(piles: piles)
     }

     internal init(piles: [Pile]) {
         self.piles = piles
     }
         
     public init() {
         // Create GamePileIndex.count piles
         resetPiles()
         // Populate piles
         populatePiles()
     }
     
     func printPiles() {
         for index in GamePileIndex.allCases {
             print(index, piles[index.rawValue].cards.map({$0.description}))
         }
     }
     
     // TODO: Replace asserts with tests
     private func populatePiles() {
         let signpostID = signposter.makeSignpostID()

         let state = signposter.beginInterval("populatePiles", id: signpostID)

         var deck: [PlayingCard] = []
         for rank in Rank.allCases {
             for suit in Suit.allCases {
                 deck.append(.init(suit: suit, rank: rank))
             }
         }
         
         signposter.emitEvent("Deck created.", id: signpostID)

         
         // There should always be 52 cards
         assert(deck.count == 52)
         
         deck.shuffle()
         signposter.emitEvent("Column population complete.", id: signpostID)

         
         var startingColumnIndex = GamePileIndex.columnOne.rawValue
         let endingColumnIndex = GamePileIndex.columnSeven.rawValue
         
         var columnPointer = startingColumnIndex
         while startingColumnIndex <= endingColumnIndex {
             guard let card = deck.popLast() else { break }
             piles[columnPointer].addCard(card)
             
             columnPointer += 1
             if columnPointer > endingColumnIndex {
                 startingColumnIndex += 1 // Advance the starting index
                 columnPointer = startingColumnIndex // Start at the advanced index
             }
         }
         
         signposter.emitEvent("Column population complete.", id: signpostID)
         
         piles.forEach({ $0.top()?.isVisible = true })

         // There should be 24 cards left
         assert(deck.count == 24)
         
         while !deck.isEmpty {
             guard let card = deck.popLast() else { break }
             piles[GamePileIndex.stock.rawValue].addCard(card)
         }
         signposter.emitEvent("Hand population complete.", id: signpostID)
         
         signposter.endInterval("populatePiles", state)
     }
     
     private func resetPiles() {
         for id in GamePileIndex.allCases {
             piles.append(Pile(id: id))
         }
     }
 }

 // MARK: Pile Accessors
 extension SolitaireGame {
     func stock() -> Pile {
         return piles[GamePileIndex.stock.rawValue]
     }
     
     func waste() -> Pile {
         return piles[GamePileIndex.waste.rawValue]
     }
     
     func foundation() -> [Pile] {
         return [
             piles[GamePileIndex.foundationOne.rawValue],
             piles[GamePileIndex.foundationTwo.rawValue],
             piles[GamePileIndex.foundationThree.rawValue],
             piles[GamePileIndex.foundationFour.rawValue],
         ]
     }
     
     func columns() -> [Pile] {
         return [
             piles[GamePileIndex.columnOne.rawValue],
             piles[GamePileIndex.columnTwo.rawValue],
             piles[GamePileIndex.columnThree.rawValue],
             piles[GamePileIndex.columnFour.rawValue],
             piles[GamePileIndex.columnFive.rawValue],
             piles[GamePileIndex.columnSix.rawValue],
             piles[GamePileIndex.columnSeven.rawValue],
         ]
     }
     
     func foundation(at index: Int) -> Pile {
         let index = GamePileIndex.foundationOne.rawValue + index
         return piles[index]
     }

     func column(at index: Int) -> Pile {
         let index = GamePileIndex.columnOne.rawValue + index
         return piles[index]
     }
 }

 // MARK: Undo & Redo
 extension SolitaireGame {
     func undo() {
         undoManager.undo()
     }
     
     func redo() {
         undoManager.redo()
     }
 }

 // MARK: Movement
 extension SolitaireGame {
     func drawFromStock() {
         let result = move(.drawStock)
         
         // Check to see if we could draw a card, if not put the waste back into the stock
         if !result {
             move(.reStock)
         }
     }
     
     func canSelectCardInPile(card: PlayingCard, pile: Pile) -> Bool {
         var lastCard: PlayingCard = card
         guard let cardIndex = pile.cards.firstIndex(of: card) else { return false }
        
         for i in (cardIndex + 1)..<pile.cards.count {
             guard lastCard.isInSequence(pile.cards[i]) && lastCard.isOppositeColor(pile.cards[i]) else { return false }
             lastCard = pile.cards[i]
         }
         
         return true
     }
     
     @discardableResult
     func move(_ move: SolitaireMove) -> Bool {
         switch move {
         case .regular(let card, let sourcePile, let destinationPile):
             moveCard(card: card, from: sourcePile, to: destinationPile)
         case .reStock:
             restock()
         case .drawStock:
             drawStock()
         case .none:
             false
         }
     }
     
     @discardableResult
     private func moveCard(card: PlayingCard, from pile: Pile, to destination: Pile) -> Bool {
         guard isValidMove(card, to: destination) else { return false }
         guard let index = pile.cards.firstIndex(of: card) else { return false }
         guard isValidCardRun(below: index, in: pile) else { return false }
         let runLength = pile.cards.count - index
         let cardsToMove = pile.pop(count: runLength)
         let originalCardstoMove = cardsToMove.map({$0.copy()})
         
         destination.addCards(cardsToMove)
         
         var scoreChange: Int = 0
         
         // Make the card above the moved card visible
         if index >= 1 {
             if !pile.cards[index - 1].isVisible {
                 scoreChange += ScoreEvent.uncoverCard.rawValue
                 pile.cards[index - 1].isVisible = true
             }
         }
         
         if !pile.isFoundation && destination.isFoundation, let scoredFoundation = highestScoredFoundationRank[destination.id] {
             if let rank = scoredFoundation {
                 if card.rank > rank {
                     // Last scored rank, is less than the cards rank so score it
                     scoreChange += ScoreEvent.movetoFoundation.rawValue
                 }
             } else {
                 // Last rank was unscored so score it, the rank will be set right after this
                 scoreChange += ScoreEvent.movetoFoundation.rawValue
             }
             
             highestScoredFoundationRank[destination.id] = card.rank
         }

         score += scoreChange
         moves += 1
         
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
         
         return true
     }
     
     private func isValidCardRun(below index: Int, in pile: Pile) -> Bool {
         var lastCard: PlayingCard = pile.cards[index]

         for i in (index + 1)..<pile.cards.count {
             guard lastCard.isInSequence(pile.cards[i]) && lastCard.isOppositeColor(pile.cards[i]) else { return false }
             lastCard = pile.cards[i]
         }
         
         return true
     }
     
     private func isValidMove(_ card: PlayingCard, to destination: Pile) -> Bool {
         return true
         if destination.isEmpty {
             // If the destination is empty, only allow an ace in a foundation pile, and a king in any other pile
             if destination.isFoundation {
                 return card.rank == .ace
             } else if card.rank == .king {
                 return true
             }
         } else if let topCard = destination.top() {
             // If the destination is the foundation, only drop if the card is less than the new card & of the same color & of the same suit
             if destination.isFoundation {
                 return topCard.isLessThan(card) && card.isInSequence(topCard) && topCard.isSameColor(card) && topCard.isSameSuitAs(card)
             }
             
             // Only allow a drop if the card is in sequence with the top card and they are different colors
             return topCard.isInSequence(card) && topCard.isOppositeColor(card)
         }
         
         return false
     }
     
     private func drawStock() -> Bool {
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
         
         return true
     }
     
     private func restock() -> Bool {
         guard !waste().isEmpty else { return false }
         
         waste().reverse()
         waste().cards.forEach({$0.isVisible = false})
         swapPiles(waste(), stock())
         restocks += 1
         
         // Score restack
         var scoreChange: Int = 0
         switch restocks {
         case 1..<4:
             scoreChange = (ScoreEvent.restock.rawValue * 2)
         case 4...:
             scoreChange = ScoreEvent.restock.rawValue
         default:
             break
         }
         score += scoreChange
         moves += 1
         
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
         
         return true
     }
         
     private func swapPiles(_ pile1: Pile, _ pile2: Pile) {
         let pile1Cards = pile1.cards
         pile1.cards = pile2.cards
         pile2.cards = pile1Cards
     }
 }

 // Game State
 extension SolitaireGame {
     internal func isGameWon() -> Bool {
         // Check to make sure all piles that are not the foundation are empty
         for pile in piles where !pile.isFoundation {
             guard pile.isEmpty else { return false }
         }
         
         
         let foundationPiles = foundation()
         
         // Check to make sure the foundation is in order and all the same suit
         for foundationPile in foundationPiles {
             guard var lastCard: PlayingCard = foundationPile.cards.first else { return false }
             guard lastCard.rank == .ace else { return false }
             let foundationSuit = lastCard.suit
             
             // Skip the first card because we have already set it as the lastCard and checked it is an ace
             for card in Array(foundationPile.cards.dropFirst()) {
                 guard card.isInSequence(lastCard) else { print("Card not in sequence: \(card), \(lastCard)"); return false }
                 guard card.suit == foundationSuit else { print("Card not the same suit \(card), \(foundationSuit)"); return false }
                 
                 lastCard = card
             }
         }
         
         return true
     }
     
     internal func validMoves() -> [SolitaireMove] {
         let signpostID = signposter.makeSignpostID()

         let state = signposter.beginInterval("validMoves", id: signpostID)
         
         var validMoves: [SolitaireMove] = []
                 
         // Check columns moving to other columns
         for sourcePile in columns() {
             validMoves.append(contentsOf: checkValidMoves(for: sourcePile, against: columns()))
         }
         
         signposter.emitEvent("Checked columns moving to columns.", id: signpostID)

         // Check columns moving to foundation
         for sourcePile in columns() {
             validMoves.append(contentsOf: checkValidMoves(for: sourcePile, against: foundation()))
         }
         
         signposter.emitEvent("Checked columns moving to foundation.", id: signpostID)

         
         // Check moving from the foundation to columns
         for sourcePile in foundation() {
             validMoves.append(contentsOf: checkValidMoves(for: sourcePile, against: columns()))
         }
         
         signposter.emitEvent("Checked foundation moving to columns.", id: signpostID)

         // Check moving from the waste into the foundation if the game rules allow
         if config.canMoveFromWasteToFoundation {
             validMoves.append(contentsOf: checkValidMoves(for: waste(), against: foundation()))
             signposter.emitEvent("Checked moving waste to foundation.", id: signpostID)
         }

         
         // Check moving from the waste into any of the columns
         validMoves.append(contentsOf: checkValidMoves(for: waste(), against: columns()))
         
         signposter.emitEvent("Checked moving waste to columns.", id: signpostID)
                 
         // Move card from stock into waste
         if !stock().isEmpty {
             validMoves.append(.drawStock)
         }
         
         // Reset the entire waste into the stock
         if stock().isEmpty && !waste().isEmpty {
             validMoves.append(.reStock)
         }
         
         signposter.endInterval("validMoves", state)
         return validMoves
     }
     
     private func checkValidMoves(for sourcePile: Pile, against destinationPiles: [Pile]) -> [SolitaireMove] {
         var validMoves: [SolitaireMove] = []

         for card in sourcePile.cards where card.isVisible {
             for destinationPile in destinationPiles {
                 if let index = sourcePile.cards.firstIndex(of: card) {
                     guard isValidCardRun(below: index, in: sourcePile) else { continue }
                 }
                 
                 guard isValidMove(card, to: destinationPile) else { continue }
                 validMoves.append(.regular(card: card, sourcePile: sourcePile, destinationPile: destinationPile))
             }
         }
         
         return validMoves
     }
 }

 extension SolitaireGame: Copyable {
     func copy() -> SolitaireGame {
         let piles = self.piles.map({$0.copy()})
         return SolitaireGame(piles: piles)
     }
 }

 */
