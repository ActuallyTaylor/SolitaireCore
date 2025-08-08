//
//  GamePileIndex.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/15/25.
//

public enum GamePileIndex: Int, CaseIterable {
    case stock
    case waste
    case foundationOne
    case foundationTwo
    case foundationThree
    case foundationFour
    case columnOne
    case columnTwo
    case columnThree
    case columnFour
    case columnFive
    case columnSix
    case columnSeven

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
