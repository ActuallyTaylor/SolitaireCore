//
//  Scorekeeper.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 8/7/25.
//

class ScoreKeeper {
    // Used to track what moves into the foundation have been scored, and not re-score them
    private var highestScoredFoundationRank: [GamePileIndex: Rank?] = [
        .foundationOne: .none,
        .foundationTwo: .none,
        .foundationThree: .none,
        .foundationFour: .none
    ]

    // Returns an integer because the score can possibly be negative or positive.
    func scoreRegularMove(card: PlayingCard, source: Pile, destination: Pile, cardIndex index: Int) -> Int {
        var scoreChange: Int = 0
        
        // Make the card above the moved card visible. This shouldn't be done in the waste since all cards are visible.
        if index >= 1 && source.id != .waste {
            if !source.cards[index - 1].isVisible {
                scoreChange += Int(ScoreEvent.uncoverCard.scoreChange)
                source.cards[index - 1].isVisible = true
            }
        }

        // Score moving a card into the foundation. This also checks to make sure you can't repeatedly score a foundation move by moving it in and out of the foundation.
        if !source.isFoundation && destination.isFoundation, let scoredFoundation = highestScoredFoundationRank[destination.id] {
            if let rank = scoredFoundation {
                if card.rank > rank {
                    // Last scored rank, is less than the card's rank so score it
                    scoreChange += Int(ScoreEvent.moveToFoundation.scoreChange)
                }
            } else {
                // Last rank was un-scored so score it, the rank will be set right after this
                scoreChange += Int(ScoreEvent.moveToFoundation.scoreChange)
            }

            highestScoredFoundationRank[destination.id] = card.rank
        }
        
        
        // Score moving out of the waste into a non-foundation pile
        if source.id == .waste && !destination.isFoundation {
            scoreChange += Int(ScoreEvent.moveFromWaste.scoreChange)
        }
        
        // Score moving cards between columns
        if source.isColumn && destination.isColumn {
            scoreChange += Int(ScoreEvent.moveToAnotherPile.scoreChange)
        }
        
        // Score moving a card from the foundation to a column.
        if source.isFoundation && destination.isColumn {
            scoreChange -= Int(ScoreEvent.moveAwayFromFoundation.scoreChange)
        }

        return scoreChange
    }
    
    // Return a score integer (UInt16) since this will always be subtracted from the score in the restock function.
    func scoreRestock(restocks: RestockInteger, drawMode: DrawMode) -> ScoreInteger {
        switch drawMode {
        case .one:
            // In draw one, subtract score after one pass through the stock
            restocks > 1 ? ScoreEvent.restockDrawOne.scoreChange : 0
        case .three:
            // In draw three, subtract score after four passes through the stock
            restocks > 4 ? ScoreEvent.restockDrawThree.scoreChange : 0
        }
    }
}
