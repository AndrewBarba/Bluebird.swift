//
//  Promise+Catch.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    /// Catches an error in a Promise chain and allows the chain to recover to a new Promise
    ///
    /// - parameter queue:   dispatch queue to run the catch handler on
    /// - parameter handler: block to run when Promise chain rejects
    ///
    /// - returns: Promise
    public func `catch`<A>(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> Promise<A>) -> Promise<A> {
        return Promise<A> { resolve, reject in
            addHandlers([
                .reject(queue, {
                    do {
                        try handler($0).addHandlers([
                            .resolve(.main, resolve),
                            .reject(.main, reject)
                        ])
                    } catch {
                        return reject(error)
                    }
                })
            ])
        }
    }

    /// Catches an error in a Promise chain and allows the chain to recover to a new Promise
    ///
    /// - parameter queue:   dispatch queue to run the catch handler on
    /// - parameter handler: block to run when Promise chain rejects
    ///
    /// - returns: Promise
    @discardableResult
    public func `catch`<A>(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> A) -> Promise<A> {
        return self.catch(on: queue) {
            try Promise<A>(resolve: handler($0))
        }
    }
}
