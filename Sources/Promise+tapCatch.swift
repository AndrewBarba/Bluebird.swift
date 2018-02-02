//
//  Promise+tapCatch.swift
//  Bluebird
//
//  Created by Andrew Barba on 2/2/18.
//

import Foundation

extension Promise {

    /// React to an error in a promise chain without recovering the chain from that error, useful for error logging
    ///
    /// - parameter queue:   dispatch queue to run the handler on
    /// - parameter handler: block to run in the middle of the promise chain. Chain waits for the returned Promise to resolve
    ///
    /// - returns: Promise that resolves to the result of the previous Promise
    public func tapCatch<A>(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> Promise<A>) -> Promise<Result> {
        return Promise<Result> { resolve, reject in
            addHandlers([
                .resolve(queue, resolve),
                .reject(queue, { error in
                    do {
                        try handler(error).finally { reject(error) }
                    } catch(_) {
                        reject(error)
                    }
                })
            ])
        }
    }

    /// React to an error in a promise chain without recovering the chain from that error, useful for error logging
    ///
    /// - parameter queue:   dispatch queue to run the handler on
    /// - parameter handler: block to run in the middle of the promise chain
    ///
    /// - returns: Promise that resolves to the result of the previous Promise
    @discardableResult public func tapCatch(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> Void) -> Promise<Result> {
        return tapCatch(on: queue) {
            try Promise<Void>(resolve: handler($0))
        }
    }
}
