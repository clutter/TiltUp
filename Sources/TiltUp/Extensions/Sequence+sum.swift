//
//  Sequence+sum.swift
//  TiltUp
//
//  Created by Erik Strottmann on 12/15/20.
//

extension Sequence {
     /// Applies the given closure to each element of the sequence, adds the
     /// transformed elements together, and returns the result.
     ///
     /// - Parameter transform: A closure that accepts an element of this
     ///   sequence and returns a value of an `AdditiveArithmetic` type, to be
     ///   added together with the other transformed elements.
     /// - Returns: The final summed value. If the sequence is empty, the result
     ///   is `.zero`.
     public func sum<Result>(
         _ transform: (Element) throws -> Result
     ) rethrows -> Result where Result: AdditiveArithmetic {
         return try map(transform).reduce(.zero, +)
     }
}

extension Sequence where Element: AdditiveArithmetic {
     /// Adds the sequence’s elements together and returns the result.
     ///
     /// - Returns: The final summed value. If the sequence is empty, the result
     ///   is `.zero`.
     public func sum() -> Element {
         return sum { $0 }
     }
 }
