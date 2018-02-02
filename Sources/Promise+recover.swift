//
//  Promise+recover.swift
//  Bluebird
//
//  Created by Andrew Barba on 2/2/18.
//

import Foundation

extension Promise {

    /// Catch a Promise rejection and recover from it if possible
    ///
    /// - parameter queue:   dispatch queue to run the handler on
    /// - parameter handler: handler that returns a Promise used to recover the rejected Promise
    ///
    /// - returns: Promise
    public func recover(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> Promise<Result>) -> Promise<Result> {
        return Promise<Result> { resolve, reject in
            addHandlers([
                .resolve(queue, resolve),
                .reject(queue, {
                    do {
                        try handler($0).addHandlers([
                            .resolve(queue, resolve),
                            .reject(queue, reject)
                        ])
                    } catch {
                        return reject(error)
                    }
                })
            ])
        }
    }

    /// Catch a Promise rejection and recover from it if possible
    ///
    /// - parameter queue:   dispatch queue to run the handler on
    /// - parameter handler: handler that returns a value used to recover the rejected Promise
    ///
    /// - returns: Promise
    public func recover(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> Result) -> Promise<Result> {
        return self.recover(on: queue) {
            try Promise<Result>(resolve: handler($0))
        }
    }
}
