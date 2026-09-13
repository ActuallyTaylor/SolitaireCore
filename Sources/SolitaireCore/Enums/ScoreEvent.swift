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
    /// This value is subtracted when scoring. When a card is moved out of the foundation it is a penalty. This is kept as a positive number here to allow the callsit to do `-=` which feels better and is easier to read.
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
            /// This value is subtracted when scoring, so it subtracts 15 from the score.
            15
        }
    }
}
