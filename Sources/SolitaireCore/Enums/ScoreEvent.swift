//
//  ScoreEvent.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

enum ScoreEvent {
    case uncoverCard
    case moveFromWaste
    
    case moveToFoundation
    
    case restockDrawThree
    case restockDrawOne

    case moveToAnotherPile
    
    case tenSecondPenalty
    case moveAwayFromFoundation

    var scoreChange: UInt16 {
        switch self {
        case .uncoverCard:
            5
        case .moveFromWaste:
            5
        case .moveToFoundation:
            10
        case .restockDrawThree:
            20
        case .restockDrawOne:
            100
        case .moveToAnotherPile:
            3
        case .tenSecondPenalty:
            10
        case .moveAwayFromFoundation:
            15
        }
    }
    
    var subtract: Bool {
        switch self {
        case .uncoverCard, .moveToFoundation, .moveToAnotherPile, .moveAwayFromFoundation, .moveFromWaste:
            return false
        case .restockDrawOne, .restockDrawThree, .tenSecondPenalty:
            return true
        }
    }
}
