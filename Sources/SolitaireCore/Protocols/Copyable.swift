//
//  Copiable.swift
//  solitaire
//
//  Created by Taylor Lineman on 4/16/25.
//

protocol Copyable: AnyObject {
    func copy() -> Self
}
