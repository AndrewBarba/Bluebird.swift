//
//  Promise+map.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Map an array of items to Promises, and resolve when all Promises resolve. Rejects as soon as any Promise rejects.
///
/// - parameter queue:     dispatch queue to run the handler on
/// - parameter items:     items to map
/// - parameter transform: transform function run on each item
///
/// - returns: Promise
public func map<A, B, S: Sequence>(on queue: DispatchQueue = .main, _ items: S, _ transform: @escaping (A) throws -> Promise<B>) -> Promise<[B]> where S.Iterator.Element == A {
    return Bluebird.try(on: queue) {
        do {
            return all(on: queue, try items.map { try transform($0) })
        } catch {
            return Promise<[B]>(reject: error)
        }
    }
}

/// Map an array of items to Promises, and resolve each Promise in series. Rejects as soon as any Promise rejects.
///
/// - parameter queue:     dispatch queue to run the handler on
/// - parameter items:     items to map
/// - parameter transform: transform function run on each item
///
/// - returns: Promise
public func map<A, B, S: Sequence>(on queue: DispatchQueue = .main, series items: S, _ transform: @escaping (A) throws -> Promise<B>) -> Promise<[B]> where S.Iterator.Element == A {
    let initial = Promise<[B]>(resolve: [])

    return items.reduce(initial) { chain, item in
        return chain.then(on: queue) { results in
            try transform(item).then(on: queue) { results + [$0] }
        }
    }
}

extension Promise where Result: Sequence {

    /// Identical to `map()`, but can be chained on an existing promise that resolves to a sequence type
    ///
    /// - parameter queue:     dispatch queue to run the handler on
    /// - parameter transform: transform function to run on each item
    ///
    /// - returns: Promise
    public func map<B>(on queue: DispatchQueue = .main, _ transform: @escaping (Result.Iterator.Element) throws -> Promise<B>) -> Promise<[B]> {
        return then(on: queue) { results in
            return Bluebird.map(on: queue, results, transform)
        }
    }

    /// Identical to `map(series)`, but can be chained on an existing promise that resolves to a sequence type
    ///
    /// - parameter queue:     dispatch queue to run the handler on
    /// - parameter transform: transform function to run on each item
    ///
    /// - returns: Promise
    public func mapSeries<B>(on queue: DispatchQueue = .main, _ transform: @escaping (Result.Iterator.Element) throws -> Promise<B>) -> Promise<[B]> {
        return then(on: queue) { results in
            return Bluebird.map(on: queue, series: results, transform)
        }
    }
}
