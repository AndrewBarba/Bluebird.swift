//
//  Promise+Catch.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    /// Catches an error in a Promise chain and allows the chain to recover
    ///
    /// - parameter queue:   dispatch queue to run the catch handler on
    /// - parameter handler: block to run when Promise chain rejects
    ///
    /// - returns: Promise
    @discardableResult public func `catch`(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> Void) -> Promise<Void> {
        return Promise<Void> { resolve, reject in
            addHandlers([
                .resolve(queue) { _ in
                    resolve(())
                },
                .reject(queue, {
                    do {
                        try handler($0)
                    } catch {
                        return reject(error)
                    }
                    resolve(())
                })
            ])
        }
    }

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
