//
//  SolitaireMove.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

public enum SolitaireMove {
    case regular(card: PlayingCard, sourcePile: Pile, destinationPile: Pile)
    case reStock
    case drawStock(drawMode: DrawMode)
    case none
}
