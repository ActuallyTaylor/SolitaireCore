//
//  PlayingCard.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/15/25.
//

public final class PlayingCard: CustomStringConvertible {
    public let suit: Suit
    public let rank: Rank

    public internal(set) var pile: Pile?
    public internal(set) var isVisible: Bool = false

    public var color: Suit.SuitColor { suit.color }
    public var description: String { "\(rank.description)\(suit.description)" }
    public var spelledDescription: String { "\(rank.spelled) of \(suit.spelled)" }

    public init(suit: Suit, rank: Rank, visible: Bool = false) {
        self.suit = suit
        self.rank = rank
        self.isVisible = visible
    }

    /*
        Bit: 7   6 5 4    3 2 1 0
         ^   ^^^^^    ^^^^^^
         |     |        |
      visible  suit     rank
       (1b)    (3b)     (4b)
    */
    public init?(data: UInt8) {
        self.isVisible = ((data & 0b10000000) >> 7) != 0

        // Remove the byte used to track visibility
        let data = data & 0b01111111
        let suitByte = (data & 0xF0) >> 4
        let rankByte = data & 0x0F

        guard let suit = Suit(rawValue: suitByte) else { return nil }
        guard let rank = Rank(rawValue: rankByte) else { return nil }

        self.suit = suit
        self.rank = rank
    }

    public func data() -> UInt8 {
        var zeroed: UInt8 = 0
        zeroed |= suit.rawValue
        zeroed <<= 4
        zeroed |= rank.rawValue

        if isVisible {
            zeroed |= 0b10000000
        }

        return zeroed
    }

    #if !hasFeature(Embedded)
    // Embedded swift does not support string splitting without extra packages, so do not include this.
    init?(string: String) {
        guard !string.isEmpty else { return nil }

        let stringSuit = String(string.last!)

        guard let newSuit = Suit.from(stringSuit) else { return nil }
        self.suit = newSuit

        let rankString = String(string.dropLast())
        guard let newRank = Rank.from(rankString) else { return nil }
        self.rank = newRank
    }
    #endif

    func isSameSuitAs(_ other: PlayingCard) -> Bool {
        suit == other.suit
    }

    func isOppositeColor(_ other: PlayingCard) -> Bool {
        color != other.color
    }

    func isSameColor(_ other: PlayingCard) -> Bool {
        color == other.color
    }

    func isLessThan(_ other: PlayingCard) -> Bool {
        rank.rawValue < other.rank.rawValue
    }

    func isInSequence(_ other: PlayingCard) -> Bool {
        self.rank == Rank(rawValue: other.rank.rawValue + 1)
    }
}

extension PlayingCard: Copyable {
    func copy() -> PlayingCard {
        let card = PlayingCard(suit: self.suit, rank: self.rank)
        card.pile = self.pile
        card.isVisible = self.isVisible
        return card
    }
}

extension PlayingCard: Equatable, Hashable {
    public static func == (lhs: PlayingCard, rhs: PlayingCard) -> Bool {
        lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(suit)
        hasher.combine(rank)
    }
}

