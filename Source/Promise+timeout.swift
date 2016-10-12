//
//  Promise+timeout.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/11/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    /// Reject the receiving Promise if it does not resolve / reject after a given number of seconds
    ///
    /// - parameter queue: dispatch queue to reject on
    /// - parameter ms:    seconds to wait before rejecting the Promise
    ///
    /// - returns: Promise
    public func timeout(on queue: DispatchQueue = .main, _ seconds: TimeInterval, _ error: Error? = nil) -> Promise<Result> {
        return Promise<Result> { resolve, reject in
            addHandlers([
                .resolve(queue, resolve),
                .reject(queue, reject)
            ])
            queue.asyncAfter(deadline: .now() + seconds) {
                reject(error ?? BluebirdError.timeout(seconds))
            }
        }
    }
}
