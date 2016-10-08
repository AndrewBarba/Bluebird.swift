//
//  Promise+race.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Returns a Promise that resolves as soon as one passed in Promise resolves
///
/// - parameter queue:    dispatch queue to run the handler on
/// - parameter promises: comma separated list of Promises to resolve
///
/// - returns: Promise that resolves to first resolved Promise
public func any<A>(on queue: DispatchQueue = .main, _ promises: Promise<A>...) -> Promise<A> {
    return any(on: queue, promises)
}

/// Returns a Promise that resolves as soon as one passed in Promise resolves
///
/// - parameter queue:    dispatch queue to run the handler on
/// - parameter promises: array of Promises to resolve
///
/// - returns: Promise that resolves to first resolved Promise
public func any<A, S: Sequence>(on queue: DispatchQueue = .main, _ promises: S) -> Promise<A> where S.Iterator.Element == Promise<A> {
    guard Array(promises).count > 0 else {
        return Promise<A>(reject: BluebirdError.rangeError)
    }

    return Promise<A> { resolve, reject in
        promises.forEach {
            $0.addHandlers([
                .resolve(queue, resolve),
                .reject(queue, reject)
            ])
        }
    }
}
