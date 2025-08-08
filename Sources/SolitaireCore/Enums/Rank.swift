//
//  Rank.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

public enum Rank: UInt8, CaseIterable, Hashable, Comparable, Sendable {
    case ace
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case jack
    case queen
    case king

    public var description: String {
        switch self {
        case .ace:
            return "A"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .ten:
            return "10"
        case .jack:
            return "J"
        case .queen:
            return "Q"
        case .king:
            return "K"
        }
    }

    public var spelled: String {
        switch self {
        case .ace:
            return "ace"
        case .two:
            return "two"
        case .three:
            return "three"
        case .four:
            return "four"
        case .five:
            return "five"
        case .six:
            return "six"
        case .seven:
            return "seven"
        case .eight:
            return "eight"
        case .nine:
            return "nine"
        case .ten:
            return "ten"
        case .jack:
            return "jack"
        case .queen:
            return "queen"
        case .king:
            return "king"
        }
    }


    static func from(_ string: String) -> Rank? {
        switch string {
        case "A":
            return .ace
        case "2":
            return .two
        case "3":
            return .three
        case "4":
            return .four
        case "5":
            return .five
        case "6":
            return .six
        case "7":
            return .seven
        case "8":
            return .eight
        case "9":
            return .nine
        case "10":
            return .ten
        case "J":
            return .jack
        case "Q":
            return .queen
        case "K":
            return .king
        default:
            return nil
        }
    }

    public static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
