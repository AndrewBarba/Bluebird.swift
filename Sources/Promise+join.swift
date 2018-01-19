//
//  Promise+Join.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

import Foundation

/// Returns a Promise that resolves to a tuple of the passed in Promises. Rejects as soon as one Promise rejects.
///
/// - parameter queue: dispatch queue to run the handler on
/// - parameter a:     Promise to join
/// - parameter b:     Promise to join
///
/// - returns: Promise
public func join<A, B>(on queue: DispatchQueue = .main, _ a: Promise<A>, _ b: Promise<B>) -> Promise<(A, B)> {
    return all(on: queue, [a.asVoid, b.asVoid]).then(on: queue) { _ in
        return Promise<(A, B)>(resolve: (a.result!, b.result!))
    }
}

/// Returns a Promise that resolves to a tuple of the passed in Promises. Rejects as soon as one Promise rejects.
///
/// - parameter queue: dispatch queue to run the handler on
/// - parameter a:     Promise to join
/// - parameter b:     Promise to join
/// - parameter c:     Promise to join
///
/// - returns: Promise
public func join<A, B, C>(on queue: DispatchQueue = .main, _ a: Promise<A>, _ b: Promise<B>, _ c: Promise<C>) -> Promise<(A, B, C)> {
    return all(on: queue, [a.asVoid, b.asVoid, c.asVoid]).then(on: queue) { _ in
        return Promise<(A, B, C)>(resolve: (a.result!, b.result!, c.result!))
    }
}

/// Returns a Promise that resolves to a tuple of the passed in Promises. Rejects as soon as one Promise rejects.
///
/// - parameter queue: dispatch queue to run the handler on
/// - parameter a:     Promise to join
/// - parameter b:     Promise to join
/// - parameter c:     Promise to join
/// - parameter d:     Promise to join
///
/// - returns: Promise
public func join<A, B, C, D>(on queue: DispatchQueue = .main, _ a: Promise<A>, _ b: Promise<B>, _ c: Promise<C>, _ d: Promise<D>) -> Promise<(A, B, C, D)> {
    return all(on: queue, [a.asVoid, b.asVoid, c.asVoid, d.asVoid]).then(on: queue) { _ in
        return Promise<(A, B, C, D)>(resolve: (a.result!, b.result!, c.result!, d.result!))
    }
}
