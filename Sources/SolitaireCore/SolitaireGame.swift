//
//  SolitaireGame.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/15/25.
//

#if PROFILE
import os
#endif

#if !hasFeature(Embedded)
import Foundation
#endif

struct GameConfiguration {
    let canMoveFromWasteToFoundation: Bool
    let undoAddsMove: Bool
}

public final class SolitaireGame {
    private let undoManager: SolitaireUndoManager = SolitaireUndoManager()

    internal let config: GameConfiguration = .init(
        canMoveFromWasteToFoundation: true,
        undoAddsMove: true
    )

    #if PROFILE
    private let signposter = OSSignposter()
    #endif

    public static let totalCards = 52
    public static let totalPiles = 13
    public let numberOfColumns = 7
    public let numberOfFoundationSlots = 4

    // Used to track what moves into the foundation have been scored, and not re-score them
    private var highestScoredFoundationRank: [GamePileIndex: Rank?] = [
        .foundationOne: .none,
        .foundationTwo: .none,
        .foundationThree: .none,
        .foundationFour: .none
    ]

    public internal(set) var restocks: Int = 0
    public internal(set) var moves: Int = 0

    // Used to cap score at 0
    private var _score: Int = 0
    public internal(set) var score: Int {
        get { _score }
        set { _score = max(0, newValue) }
    }

//private(set)
    public var piles: [Pile] = []

    internal init(piles: [Pile]) {
        undoManager.target = self
        self.piles = piles
    }

    public init() {
        undoManager.target = self
        // Create GamePileIndex.count piles
        resetPiles()
        // Populate piles
        populatePiles()
    }

    // public func printPiles() {
    //     for index in GamePileIndex.allCases {
    //         print(index, piles[index.rawValue].cards.map({$0.description}))
    //     }
    // }

    // TODO: Replace asserts with tests
    private func populatePiles() {
        #if PROFILE
        let signpostID = signposter.makeSignpostID()

        let state = signposter.beginInterval("populatePiles", id: signpostID)
        #endif

        var deck: [PlayingCard] = []
        for rank in Rank.allCases {
            for suit in Suit.allCases {
                deck.append(.init(suit: suit, rank: rank))
            }
        }

        #if PROFILE
        signposter.emitEvent("Deck created.", id: signpostID)
        #endif

        // There should always be 52 cards
        assert(deck.count == SolitaireGame.totalCards)

        deck.shuffle()

        #if PROFILE
        signposter.emitEvent("Column population complete.", id: signpostID)
        #endif

        var startingColumnIndex = GamePileIndex.columnOne.rawValue
        let endingColumnIndex = GamePileIndex.columnSeven.rawValue

        var columnPointer = startingColumnIndex
        while startingColumnIndex <= endingColumnIndex {
            guard let card = deck.popLast() else { break }
            piles[columnPointer].add(card: card)

            columnPointer += 1
            if columnPointer > endingColumnIndex {
                startingColumnIndex += 1 // Advance the starting index
                columnPointer = startingColumnIndex // Start at the advanced index
            }
        }

        #if PROFILE
        signposter.emitEvent("Column population complete.", id: signpostID)
        #endif

        piles.forEach({ $0.top()?.isVisible = true })

        // There should be 24 cards left
        assert(deck.count == 24)

        while !deck.isEmpty {
            guard let card = deck.popLast() else { break }
            piles[GamePileIndex.stock.rawValue].add(card: card)
        }
        #if PROFILE
        signposter.emitEvent("Hand population complete.", id: signpostID)

        signposter.endInterval("populatePiles", state)
        #endif
    }

    private func resetPiles() {
        for id in GamePileIndex.allCases {
            piles.append(Pile(id: id))
        }
    }
}

// MARK: Pile Accessors
extension SolitaireGame {
    public func stock() -> Pile {
        return piles[GamePileIndex.stock.rawValue]
    }

    public func waste() -> Pile {
        return piles[GamePileIndex.waste.rawValue]
    }

    public func foundation() -> [Pile] {
        return [
            piles[GamePileIndex.foundationOne.rawValue],
            piles[GamePileIndex.foundationTwo.rawValue],
            piles[GamePileIndex.foundationThree.rawValue],
            piles[GamePileIndex.foundationFour.rawValue],
        ]
    }

    public func columns() -> [Pile] {
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

    public func foundation(at index: Int) -> Pile {
        let index = GamePileIndex.foundationOne.rawValue + index
        return piles[index]
    }

    public func column(at index: Int) -> Pile {
        let index = GamePileIndex.columnOne.rawValue + index
        return piles[index]
    }

    public func pile(at index: GamePileIndex) -> Pile {
        return piles[index.rawValue]
    }
}

// MARK: Undo & Redo
extension SolitaireGame {
    public func undo() {
        undoManager.undo()
    }

//    public func redo() {
//        undoManager.redo()
//    }
}

// MARK: Movement
extension SolitaireGame {
    public func drawFromStock() {
        let result = move(.drawStock)

        // Check to see if we could draw a card, if not put the waste back into the stock
        if !result {
            move(.reStock)
        }
    }

    public func canSelectCardInPile(card: PlayingCard, pile: Pile) -> Bool {
        var lastCard: PlayingCard = card
        guard let cardIndex = pile.cards.firstIndex(of: card) else { return false }

        for i in (cardIndex + 1)..<pile.cards.count {
            guard lastCard.isInSequence(pile.cards[i]) else { return false }
            guard lastCard.isOppositeColor(pile.cards[i]) else { return false }
            guard lastCard.isVisible else { return false }
            lastCard = pile.cards[i]
        }

        return true
    }

    @discardableResult
    public func move(_ move: SolitaireMove) -> Bool {
        switch move {
        case .regular(let card, let sourcePile, let destinationPile):
            return moveCard(card: card, from: sourcePile, to: destinationPile)
        case .reStock:
            return restock()
        case .drawStock:
            return drawStock()
        case .none:
            return false
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

        destination.add(cards: cardsToMove)

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
                // Last rank was un-scored so score it, the rank will be set right after this
                scoreChange += ScoreEvent.movetoFoundation.rawValue
            }

            highestScoredFoundationRank[destination.id] = card.rank
        }

        score += scoreChange
        moves += 1

        undoManager.registerUndo(package: .moveCards(cards: originalCardstoMove, source: pile, destination: destination, scoreChange: scoreChange))
        
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
        waste().add(card: topOfStock)
        topOfStock.isVisible = true

        moves += 1

        undoManager.registerUndo(package: .drawStock(card: originalCardState, scoreChange: 1))

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
        
        undoManager.registerUndo(package: .restock)

        return true
    }

    internal func swapPiles(_ pile1: Pile, _ pile2: Pile) {
        let pile1Cards = pile1.cards
        pile1.cards = pile2.cards
        pile2.cards = pile1Cards
    }
}

// Game State
extension SolitaireGame {
    public func isGameWon() -> Bool {
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
}

// MARK: Invalid Moves
extension SolitaireGame {
    // TODO: This SHOULD NOT call validMoves. That value should be cached
    public func getNumberOfValidMoves() -> Int {
        return validMoves().count
    }

    internal func validMoves() -> [SolitaireMove] {
        #if PROFILE
        let signpostID = signposter.makeSignpostID()

        let state = signposter.beginInterval("validMoves", id: signpostID)
        #endif

        var validMoves: [SolitaireMove] = []

        // Check columns moving to other columns
        for sourcePile in columns() {
            validMoves.append(contentsOf: checkValidMoves(for: sourcePile, against: columns()))
        }

        #if PROFILE
        signposter.emitEvent("Checked columns moving to columns.", id: signpostID)
        #endif

        // Check columns moving to foundation
        for sourcePile in columns() {
            validMoves.append(contentsOf: checkValidMoves(for: sourcePile, against: foundation()))
        }

        #if PROFILE
        signposter.emitEvent("Checked columns moving to foundation.", id: signpostID)
        #endif

        // Check moving from the foundation to columns
        for sourcePile in foundation() {
            validMoves.append(contentsOf: checkValidMoves(for: sourcePile, against: columns()))
        }

        #if PROFILE
        signposter.emitEvent("Checked foundation moving to columns.", id: signpostID)
        #endif

        // Check moving from the waste into the foundation if the game rules allow
        if config.canMoveFromWasteToFoundation {
            validMoves.append(contentsOf: checkValidMoves(for: waste(), against: foundation()))
            #if PROFILE
            signposter.emitEvent("Checked moving waste to foundation.", id: signpostID)
            #endif
        }


        // Check moving from the waste into any of the columns
        validMoves.append(contentsOf: checkValidMoves(for: waste(), against: columns()))

        #if PROFILE
        signposter.emitEvent("Checked moving waste to columns.", id: signpostID)
        #endif

        // Move card from stock into waste
        if !stock().isEmpty {
            validMoves.append(.drawStock)
        }

        // Reset the entire waste into the stock
        if stock().isEmpty && !waste().isEmpty {
            validMoves.append(.reStock)
        }

        #if PROFILE
        signposter.endInterval("validMoves", state)
        #endif
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

// MARK: Load & Save
extension SolitaireGame {
    static let pileSeperator: UInt8 = 0xFF

    public static func loadGame(from data: [UInt8]) -> SolitaireGame {
        var separatedData: [[UInt8]] = []
        var currentData: [UInt8] = []

        for byte in data {
            if byte == Self.pileSeperator {
                separatedData.append(currentData)
                currentData = []
            } else {
                currentData.append(byte)
            }
        }

        guard separatedData.count == SolitaireGame.totalPiles else {
            print("Did not load all piles from save. Piles Loaded \(separatedData.count)")
            return SolitaireGame()
        }

        var piles: [Pile] = []

        for index in GamePileIndex.allCases {
            let separatedData = separatedData[index.rawValue]
            let cards = separatedData.compactMap({PlayingCard(data: $0)})
            guard cards.count == separatedData.count else {
                print("Failed to load card in \(separatedData)")
                continue
            }

            piles.append(Pile(id: index, cards: cards))
        }

        return SolitaireGame(piles: piles)
    }

    public static func saveGame(game: SolitaireGame) -> [UInt8] {
        var saveData: [UInt8] = []

        for index in GamePileIndex.allCases {
            let pile = game.pile(at: index)
            let cards: [UInt8] = pile.getCards().map({ $0.data() })
            saveData.append(contentsOf: cards)
            saveData.append(SolitaireGame.pileSeperator)
        }

        return saveData
    }
}

#if !hasFeature(Embedded)
// MARK: Embedded swift does not support strings without extra packages, so disable string based loading
extension SolitaireGame {
    public static func loadCompressedGame(from string: String) -> SolitaireGame {
        let uncompressedStringRep = uncompressSaveGame(string: string)
        return loadGame(from: uncompressedStringRep)
    }

    public static func loadGame(from stringRep: [[String]]) -> SolitaireGame {
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

    public static func saveCompressedGame(game: SolitaireGame) -> String {
        let uncompressedStringRep: [[String]] = saveGame(game: game)
        return compressSaveGame(stringRep: uncompressedStringRep)
    }

    public static func saveGame(game: SolitaireGame) -> [[String]] {
        var stringRep: [[String]] = []

        for index in GamePileIndex.allCases {
            let pile = game.pile(at: index)
            let strings: [String] = pile.getCards().map({$0.description})
            stringRep.append(strings)
        }

        return stringRep
    }

    public static func compressSaveGame(stringRep: [[String]]) -> String {
        return stringRep.compactMap { strings in
            return strings.joined(separator: ",")
        }.joined(separator: ";")
    }

    public static func uncompressSaveGame(string: String) -> [[String]] {
        let rows = string.split(separator: ";").map({String($0)})
        let uncompressedRows = rows.compactMap({$0.split(separator: ",").map({String($0)})})
        return uncompressedRows
    }
}
#endif
