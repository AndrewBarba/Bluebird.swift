//
//  Promise+Then.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    /// Perform an operation on a Promise once it resolves. The chain will then resolve to the Promise returned from the handler
    ///
    /// - parameter queue:   dispatch queue to run the handler on
    /// - parameter handler: block to run when Promise resolved, returns a Promsie that mutates the Promise chain
    ///
    /// - returns: Promise
    public func then<A>(on queue: DispatchQueue = .main, _ handler: @escaping (Result) throws -> Promise<A>) -> Promise<A> {
        return Promise<A> { resolve, reject in
            addHandlers([
                .resolve(queue, {
                    do {
                        try handler($0).addHandlers([
                            .resolve(.main, resolve),
                            .reject(.main, reject)
                        ])
                    } catch {
                        return reject(error)
                    }
                }),
                .reject(queue, reject)
            ])
        }
    }

    /// Perform an operation on a Promise once it resolves. The chain will then resolve to the Promise returned from the handler
    ///
    /// - parameter queue:   dispatch queue to run the handler on
    /// - parameter handler: block to run when Promise resolved, returns a Promsie that mutates the Promise chain
    ///
    /// - returns: Promise
    @discardableResult
    public func then<A>(on queue: DispatchQueue = .main, _ handler: @escaping (Result) throws -> A) -> Promise<A> {
        return then(on: queue) {
            try Promise<A>(resolve: handler($0))
        }
    }
}
