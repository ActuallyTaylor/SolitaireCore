//
//  Pile.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/15/25.
//

public final class Pile: Identifiable, CustomStringConvertible {
    public private(set) var id: GamePileIndex
    package var cards: [PlayingCard]

    public var description: String {
        self.id.name
    }

    public var isEmpty: Bool {
        return cards.isEmpty
    }

    public var isFoundation: Bool {
        return (
            self.id == .foundationOne ||
            self.id == .foundationTwo ||
            self.id == .foundationThree ||
            self.id == .foundationFour
        )
    }
    
    public var isColumn: Bool {
        return id <= GamePileIndex.columnSeven && id >= GamePileIndex.columnOne
    }


    public init(id: GamePileIndex, cards: [PlayingCard]) {
        self.id = id
        self.cards = cards
        for card in cards {
            card.pile = self
        }
    }

    init(id: GamePileIndex) {
        self.id = id
        self.cards = []
    }

    public func getCards() -> [PlayingCard] {
        cards
    }

    public func getCard(at index: Int) -> PlayingCard {
        cards[index]
    }

    public func getCardWithRangeCheck(at index: Int) -> PlayingCard? {
        if index >= cards.count {
            return nil
        }
        return cards[index]
    }


    func add(card: PlayingCard) {
        card.pile = self
        cards.append(card)
    }

    func add(cards: [PlayingCard]) {
        for card in cards {
            card.pile = self
            card.isVisible = true
        }

        self.cards.append(contentsOf: cards)
    }

    func bottom() -> PlayingCard? {
        return cards.first
    }

    public func top() -> PlayingCard? {
        return cards.last
    }

    public func cardFromTop(offset: Int) -> PlayingCard? {
        let index = (cards.count - 1) - offset
        guard index >= 0, index < cards.count else { return nil }
        return cards[index]
    }

    public func cardBelow(playingCard: PlayingCard) -> PlayingCard? {
        if let index = cards.firstIndex(of: playingCard) {
            let belowIndex = index - 1
            guard belowIndex >= 0, belowIndex < cards.count else {
                print("FAILURE \(belowIndex)")
                 return nil
              }

            return cards[belowIndex]
        }

        return nil
    }

    func pop() -> PlayingCard? {
        guard !cards.isEmpty else { return nil }
        return cards.removeLast()
    }

    func pop(count: Int) -> [PlayingCard] {
        let actualCount = min(count, cards.count)
        let popped = Array(cards.suffix(actualCount))
        self.cards.removeLast(actualCount)
        return popped
    }

    @discardableResult
    func remove(card: PlayingCard) -> PlayingCard? {
        guard let index = cards.firstIndex(of: card) else { return nil }
        return cards.remove(at: index)
    }

    @discardableResult
    func remove(cards: [PlayingCard]) -> [PlayingCard] {
        var removedCards: [PlayingCard] = []
        for card in cards {
            if let index = self.cards.firstIndex(of: card) {
                removedCards.append(self.cards.remove(at: index))
            }
        }
        return removedCards
    }

    func reverse() {
        self.cards.reverse()
    }
}

extension Pile: Equatable, Hashable {
    public static func == (lhs: Pile, rhs: Pile) -> Bool {
        return lhs.cards == rhs.cards
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        for card in self.cards {
            hasher.combine(card.hashValue)
        }
    }
}

extension Pile: Copyable {
    public func copy() -> Pile {
        let newPile = Pile(id: self.id)
        let newCards = self.cards.map({$0.copy()})
        newPile.cards = newCards
        return newPile
    }
}
