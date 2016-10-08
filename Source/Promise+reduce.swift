//
//  Promise+reduce.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/6/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Reduce a sequence of items with a asynchronous operation (Promise) to a single value
///
/// - parameter queue:     dispatch queue to run transform on
/// - parameter initial:   initial value to begin reducing
/// - parameter items:     sequence to iterate over
/// - parameter transform: transform function that accepts a partial result and current list item
///
/// - returns: Promsie
public func reduce<A, B, S: Sequence>(on queue: DispatchQueue = .main, _ items: S, _ initial: B, _ transform: @escaping (B, A) throws -> Promise<B>) -> Promise<B> where S.Iterator.Element == A {
    let initialPromise = Promise<B>(resolve: initial)

    return items.reduce(initialPromise) { partial, item in
        return partial.then(on: queue) {
            try transform($0, item)
        }
    }
}
