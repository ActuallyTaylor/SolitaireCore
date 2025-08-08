//
//  ScoreEvent.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

enum ScoreEvent {
    case uncoverCard
    case moveToAnotherPile

    case moveFromWaste
    
    case moveToFoundation
    case moveAwayFromFoundation

    case restockDrawThree
    case restockDrawOne

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
        case .moveAwayFromFoundation:
            15
        }
    }
}
