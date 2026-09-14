//
//  GamePileIndex.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/15/25.
//

public enum GamePileIndex: Int, CaseIterable, Sendable {
    case stock = 0
    case waste = 1
    case foundationOne = 2
    case foundationTwo = 3
    case foundationThree = 4
    case foundationFour = 5
    case columnOne = 6
    case columnTwo = 7
    case columnThree = 8
    case columnFour = 9
    case columnFive = 10
    case columnSix = 11
    case columnSeven = 12

    public static var count: Int {
        return GamePileIndex.columnSeven.rawValue
    }

    public var name: String {
        switch self {
        case .stock:
            return "Stock"
        case .waste:
            return "Waste"
        case .foundationOne:
            return "Foundation One"
        case .foundationTwo:
            return "Foundation Two"
        case .foundationThree:
            return "Foundation Three"
        case .foundationFour:
            return "Foundation Four"
        case .columnOne:
            return "Column One"
        case .columnTwo:
            return "Column Two"
        case .columnThree:
            return "Column Three"
        case .columnFour:
            return "Column Four"
        case .columnFive:
            return "Column Five"
        case .columnSix:
            return "Column Six"
        case .columnSeven:
            return "Column Seven"
        }
    }
}

extension GamePileIndex: Comparable {
    public static func < (lhs: GamePileIndex, rhs: GamePileIndex) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
