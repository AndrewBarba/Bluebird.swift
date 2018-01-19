//
//  Promise+race.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

import Foundation

/// Identical to `all`, but does not throw an error for an empty array of Promises
///
/// - parameter queue:    dispatch queue to run the handler on
/// - parameter promises: promises to resolve
///
/// - returns: Promise
public func race<A>(on queue: DispatchQueue = .main, _ promises: Promise<A>...) -> Promise<A> {
    return race(on: queue, promises)
}

/// Identical to `all`, but does not throw an error for an empty array of Promises
///
/// - parameter queue:    dispatch queue to run the handler on
/// - parameter promises: promises to resolve
///
/// - returns: Promise
public func race<A, S: Sequence>(on queue: DispatchQueue = .main, _ promises: S) -> Promise<A> where S.Iterator.Element == Promise<A> {
    return Promise<A> { resolve, reject in
        promises.forEach {
            $0.addHandlers([
                .resolve(queue, resolve),
                .reject(queue, reject)
            ])
        }
    }
}
