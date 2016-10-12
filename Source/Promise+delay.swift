//
//  Promise+delay.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/11/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Delay the start of a Promise chain by some number of seconds
///
/// - parameter queue:   dispatch queue to run the delay on
/// - parameter seconds: seconds to delay execution of next handler
/// - parameter result:  the Promise to resolve to after the delay
///
/// - returns: Promise
public func delay<A>(on queue: DispatchQueue = .main, _ seconds: TimeInterval, _ result: A) -> Promise<A> {
    return Promise<A> { resolve, _ in
        queue.asyncAfter(deadline: .now() + seconds) {
            resolve(result)
        }
    }
}

/// Delay the start of a Promise chain by some number of seconds
///
/// - parameter queue:   dispatch queue to run the delay on
/// - parameter seconds: seconds to delay execution of next handler
/// - parameter promise: the Promise to resolve to after the delay
///
/// - returns: Promise
public func delay<A>(on queue: DispatchQueue = .main, _ seconds: TimeInterval, _ promise: Promise<A>) -> Promise<A> {
    return promise.then(on: queue) {
        Bluebird.delay(on: queue, seconds, $0)
    }
}

extension Promise {

    /// Delay the next handler of the Promise chain by some number of seconds
    ///
    /// - parameter queue:   dispatch queue to run the delay on
    /// - parameter seconds: seconds to delay execution of next handler
    ///
    /// - returns: Promise
    public func delay(on queue: DispatchQueue = .main, _ seconds: TimeInterval) -> Promise<Result> {
        return Bluebird.delay(on: queue, seconds, self)
    }
}
