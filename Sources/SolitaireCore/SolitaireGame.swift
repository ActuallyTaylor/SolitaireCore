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

public typealias ScoreInteger = UInt16
public typealias RestockInteger = UInt16
public typealias MoveInteger = UInt16
public typealias DataVersionInteger = UInt8

// TODO: Add tests for three draw mode
public enum DrawMode: UInt8, Sendable {
    case one
    case three
}

struct GameConfiguration {
    let canMoveFromWasteToFoundation: Bool
    let undoAddsMove: Bool
    let drawMode: DrawMode
}

public final class SolitaireGame {
    private let undoManager: SolitaireUndoManager = SolitaireUndoManager()

    internal let config: GameConfiguration = .init(
        canMoveFromWasteToFoundation: true,
        undoAddsMove: true,
        drawMode: .one
    )

    #if PROFILE
    private let signposter = OSSignposter()
    #endif

    private var scoreKeeper: ScoreKeeper = ScoreKeeper()

    public static let totalCards = 52
    public static let totalPiles = 13
    public let numberOfColumns = 7
    public let numberOfFoundationSlots = 4

    public private(set) var restocks: RestockInteger = 0
    public private(set) var moves: MoveInteger = 0
    // Used to cap score at 0
    private var _score: ScoreInteger = 0
    public private(set) var score: ScoreInteger {
        get { _score }
        set { print("Score Changed original: \(_score), new: \(newValue)"); _score = max(0, newValue) }
    }
    public private(set) var isSolved: Bool = false

    public var piles: [Pile] = []
    public private(set) var seed: UInt64


    internal init(piles: [Pile]) {
        self.seed = SolitaireGame.generateSeed()

        undoManager.target = self
        self.piles = piles
        // Check if the game inputed is a solvedGame
        self.isSolved = checkIsGameSolved()
    }

    public init() {
        self.seed = SolitaireGame.generateSeed()

        undoManager.target = self
        // Create GamePileIndex.count piles
        resetPiles()
        // Populate piles
        populatePiles()
    }

    /// Creates a Solitaire Game with the specified seed.
    /// Note: The seed may change as the version of swift changes. This is a side effect of shuffle not being a permanent implementation.
    /// - Parameter seed: The seed of the solitaire game to generate
    public init(seed: UInt64) {
        self.seed = seed

        undoManager.target = self
        // Create GamePileIndex.count piles
        resetPiles()
        // Populate piles
        populatePiles()
    }


    static func generateSeed() -> UInt64 {
        return UInt64.random(in: 0..<UInt64.max)
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

//        if seed != -1 {
//            var rng = SeededRandomNumberGenerator(seed: seed)
//            deck.shuffle(using: &rng)
//        } else {
            deck.shuffle()
//        }

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

// MARK: Score, Moves, Restock Setters
extension SolitaireGame {
    func addMoves(value: UInt16) {
        moves.safeAdd(value: value)
    }

    func subtractMoves(value: UInt16) {
        moves.safeSubtract(value: value)
    }

    func addScore(value: UInt16) {
        score.safeAdd(value: value)
    }

    func subtractScore(value: UInt16) {
        score.safeSubtract(value: value)
    }

    func addRestocks(value: UInt16) {
        restocks.safeAdd(value: value)
    }

    func subtractRestocks(value: UInt16) {
        restocks.safeSubtract(value: value)
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
    public func undo() throws(UndoError) {
        try undoManager.undo()
    }

//    public func redo() {
//        undoManager.redo()
//    }
}

// MARK: Movement
extension SolitaireGame {
    public func drawFromStock() {
        let result = move(.drawStock(drawMode: config.drawMode))

        // Check to see if we could draw a card, if not put the waste back into the stock
        if !result {
            move(.reStock)
        }
    }

    private func reInterpretAiMove(_ move: SolitaireMove) -> SolitaireMove? {
        switch move {
        case .regular(let card, let sourcePile, let destinationPile):
            let localSource = pile(at: sourcePile.id)
            let localDestination = pile(at: destinationPile.id)
            guard let localCard = localSource.cards.first(where: { $0.rank == card.rank && $0.suit == card.suit }) else {
                return nil
            }

            return .regular(card: localCard, sourcePile: localSource, destinationPile: localDestination)
        case .reStock, .drawStock, .none:
            return move
        }
    }

    @discardableResult
    public func makeAiMove(_ move: SolitaireMove) -> Bool {
        guard let reinterpretedMove = reInterpretAiMove(move) else {
            return false
        }
        return self.move(reinterpretedMove)
    }

    @discardableResult
    public func move(_ move: SolitaireMove) -> Bool {
        defer {
            self.isSolved = checkIsGameSolved()
        }

        switch move {
        case .regular(let card, let sourcePile, let destinationPile):
            return moveCard(card: card, from: sourcePile, to: destinationPile)
        case .reStock:
            return restock()
        case .drawStock(let mode):
            return drawStock(mode: mode)
        case .none:
            return false
        }
    }

    @discardableResult
    private func moveCard(card: PlayingCard, from pile: Pile, to destination: Pile) -> Bool {
        guard isValidMove(card, to: destination) else { return false }
        guard let index = pile.cards.firstIndex(of: card) else { return false }
        if destination.isFoundation {
            guard isValidCardFoundationRun(below: index, in: pile) else { return false }
        } else {
            guard isValidCardRun(below: index, in: pile) else { return false }
        }

        let runLength = pile.cards.count - index
        let cardsToMove = pile.pop(count: runLength)
        let originalCardsToMove = cardsToMove.map({$0.copy()})

        destination.add(cards: cardsToMove)

        let integerScoreChange: Int = scoreKeeper.scoreRegularMove(card: card, source: pile, destination: destination, cardIndex: index)

        var scoreChange: ScoreInteger = 0
        var negativeScoreChange = false
        if integerScoreChange >= 0 {
            // Add the value to the score
            scoreChange = UInt16(integerScoreChange)
            negativeScoreChange = false

            addScore(value: scoreChange)
        } else {
            // Subtract the value from the score. Take the negative of the integer score to make it positive
            scoreChange = UInt16(-integerScoreChange)
            negativeScoreChange = true

            subtractScore(value: scoreChange)
        }

        addMoves(value: 1)

        undoManager.registerUndo(package: .moveCards(cards: originalCardsToMove, source: pile.id, destination: destination.id, scoreChange: scoreChange, negativeScoreChange: negativeScoreChange))

        return true
    }

    private func drawStock(mode: DrawMode) -> Bool {
        var originalCards: [PlayingCard] = []
        for x in 0..<(mode == .one ? 1 : 3) {
            guard let topOfStock = stock().pop() else {
                // We only fail a stock draw if the first draw fails. When drawing more than one card, it is okay if the last 2 are failed draws and only one card is drawn.
                if x == 0 {
                    return false
                } else {
                    continue
                }
            }

            let originalCardState = topOfStock.copy()
            originalCards.append(originalCardState)
            waste().add(card: topOfStock)
            topOfStock.isVisible = true

            addMoves(value: 1)
        }

        undoManager.registerUndo(package: .drawStock(cards: originalCards))

        return true
    }

    private func restock() -> Bool {
        guard !waste().isEmpty else { return false }

        waste().reverse()
        waste().cards.forEach({$0.isVisible = false})
        swapPiles(waste(), stock())
        addRestocks(value: 1)

        // Score restock
        let penalty: UInt16 = scoreKeeper.scoreRestock(restocks: restocks, drawMode: config.drawMode)
        score.safeSubtract(value: penalty)

        addMoves(value: 1)

        undoManager.registerUndo(package: .restock(scoreChange: penalty))

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
    public func checkIsGameSolved() -> Bool {
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

// MARK: Move validation
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
            validMoves.append(.drawStock(drawMode: config.drawMode))
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

    private func isValidCardRun(below index: Int, in pile: Pile) -> Bool {
        var lastCard: PlayingCard = pile.cards[index]

        for i in (index + 1)..<pile.cards.count {
            guard lastCard.isInSequence(pile.cards[i]) && lastCard.isOppositeColor(pile.cards[i]) else { return false }
            lastCard = pile.cards[i]
        }

        return true
    }

    private func isValidCardFoundationRun(below index: Int, in pile: Pile) -> Bool {
        var lastCard: PlayingCard = pile.cards[index]

        for i in (index + 1)..<pile.cards.count {
            guard lastCard.isInSequence(pile.cards[i]) && lastCard.isSameColor(pile.cards[i]) else { return false }
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
}

// MARK: Selection
extension SolitaireGame {
    public func canAddCardToSelectionStack(card: PlayingCard, selectedCards: [PlayingCard], pickUpFrom pile: Pile) -> Bool {
        if let lastCard = selectedCards.last {
            if pile.isFoundation {
                // If it is the foundation it needs to be same color card. And it should be in reverse sequence (Card below should be less)
                return lastCard.isInSequence(card) && card.isSameSuitAs(lastCard)
            } else {
                // If it is a regular pile, card should be in sequence and the opposite color.
                return card.isInSequence(lastCard) && card.isOppositeColor(lastCard)
            }

        }

        return canSelectCardInPile(card: card, pile: pile)
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
}

extension SolitaireGame: Copyable {
    func copy() -> SolitaireGame {
        let piles = self.piles.map({$0.copy()})
        let game = SolitaireGame(piles: piles)
        game.score = self.score
        game.moves = self.moves
        game.restocks = self.restocks
        game.seed = self.seed
        game.scoreKeeper = self.scoreKeeper.copy()
        return game
    }
}

// MARK: Load & Save
extension SolitaireGame {
    static let pileSeparator: UInt8 = 0xFF
    public static let headerSize: Int = (DataVersionInteger.bitWidth + ScoreInteger.bitWidth + MoveInteger.bitWidth + RestockInteger.bitWidth) / 8

    public static func saveGame(game: SolitaireGame) -> [UInt8] {
        var saveData: [UInt8] = []

        for index in GamePileIndex.allCases {
            let pile = game.pile(at: index)
            let cards: [UInt8] = pile.getCards().map({ $0.data() })
            saveData.append(contentsOf: cards)
            saveData.append(SolitaireGame.pileSeparator)
        }

        // Save game header
        let versionByte: DataVersionInteger = 1
        let scoreBytes = game.score.bigEndianBytes
        let moveBytes = game.moves.bigEndianBytes
        let restockBytes = game.restocks.bigEndianBytes

        // Insert header in reverse
        saveData.insert(contentsOf: restockBytes, at: 0)
        saveData.insert(contentsOf: moveBytes, at: 0)
        saveData.insert(contentsOf: scoreBytes, at: 0)
        saveData.insert(versionByte, at: 0)

        print("Header Size \(headerSize) \(restockBytes.count + moveBytes.count + scoreBytes.count + 1)")

        return saveData
    }

    public static func loadGame(from data: [UInt8]) -> SolitaireGame {
        // Get header data
        let headerData: [UInt8] = Array(data[0..<headerSize])

        let score: ScoreInteger = ScoreInteger(from: Array(headerData[1...2]))
        let moves: MoveInteger = MoveInteger(from: Array(headerData[3...4]))
        let restocks = RestockInteger(from: Array(headerData[5...6]))

        // Mutate data to remove header
        let data = Array(data.dropFirst(headerSize))

        var separatedData: [[UInt8]] = []
        var currentData: [UInt8] = []

        for byte in data {
            if byte == Self.pileSeparator {
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

        let game = SolitaireGame(piles: piles)
        game.score = score
        game.moves = moves
        game.restocks = restocks

        return game
    }

    public static func gameNumber(game: SolitaireGame) -> Int {
        return 0
    }
}

#if !hasFeature(Embedded)
// MARK: Embedded swift does not support strings without extra packages, so disable string based loading
extension SolitaireGame {
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

    public static func saveGameToString(game: SolitaireGame) -> [[String]] {
        var stringRep: [[String]] = []

        for index in GamePileIndex.allCases {
            let pile = game.pile(at: index)
            let strings: [String] = pile.getCards().map({$0.description})
            stringRep.append(strings)
        }

        return stringRep
    }
}
#endif

extension SolitaireGame: Equatable {
    public static func ==(lhs: SolitaireGame, rhs: SolitaireGame) -> Bool {
        return lhs.piles == rhs.piles && lhs.score == rhs.score && lhs.restocks == rhs.restocks && lhs.moves == rhs.moves
    }
}
