//
//  Suit.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

public enum Suit: UInt8, CaseIterable, Hashable, Sendable {
    public enum SuitColor {
        case red
        case black
    }

    case spades
    case hearts
    case diamonds
    case clubs

    public var description: String {
        switch self {
        case .spades:
            return "♠"
        case .hearts:
            return "♡"
        case .diamonds:
            return "♢"
        case .clubs:
            return "♣"
        }
    }

    public var spelled: String {
        switch self {
        case .spades:
            return "spades"
        case .hearts:
            return "hearts"
        case .diamonds:
            return "diamonds"
        case .clubs:
            return "clubs"
        }
    }


    var color: SuitColor {
        if self == .spades || self == .clubs {
            return .black
        } else {
            return .red
        }
    }

    static func from(_ string: String) -> Suit? {
        switch string {
        case "♠", "S":
            return .spades
        case "♥", "H":
            return .hearts
        case "♦", "D":
            return .diamonds
        case "♣", "C":
            return .clubs
        default:
            return nil
        }
    }
}
