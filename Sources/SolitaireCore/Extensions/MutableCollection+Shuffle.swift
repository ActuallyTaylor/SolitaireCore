//
//  MutableCollection+Shuffle.swift
//  SolitaireCore
//
//  Created by Taylor Lineman on 9/13/26.
//

extension MutableCollection where Self: RandomAccessCollection {
    /// A stable implementation of Swift 6.3.3's shuffle function. Because swift does not guarantee a
    /// stable shuffle function, this is copied to provide a stable implementation for seeding decks.
    ///
    /// https://github.com/swiftlang/swift/blob/c3d134dc66cc1f8277b15e858b9866db6ebd0604/stdlib/public/core/CollectionAlgorithms.swift#L603
    ///
    ///
    /// Shuffles the collection in place, using the given generator as a source
    /// for randomness.
    ///
    /// You use this method to randomize the elements of a collection when you
    /// are using a custom random number generator. For example, you can use the
    /// `shuffle(using:)` method to randomly reorder the elements of an array.
    ///
    ///     var names = ["Alejandro", "Camila", "Diego", "Luciana", "Luis", "Sofía"]
    ///     names.shuffle(using: &myGenerator)
    ///     // names == ["Sofía", "Alejandro", "Camila", "Luis", "Diego", "Luciana"]
    ///
    /// - Parameter generator: The random number generator to use when shuffling
    ///   the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable
    public mutating func stableShuffle<T: RandomNumberGenerator>(using generator: inout T) {
        guard count > 1 else { return }
        
        var amount = count
        var currentIndex = startIndex
        
        while amount > 1 {
            let random = Int.random(in: 0 ..< amount, using: &generator)
            amount -= 1
            swapAt(currentIndex, index(currentIndex, offsetBy: random))
            formIndex(after: &currentIndex)
        }
    }
}
