//
//  Promise+Tap.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

import Foundation

extension Promise {

    /// Perform an operation in the middle of a promise chain that does not effect the resolved value, but can reject the chain
    ///
    /// - parameter queue:   dispatch queue to run the handler on
    /// - parameter handler: block to run in the middle of the promise chain. Chain waits for the returned Promise to resolve
    ///
    /// - returns: Promise that resolves to the result of the previous Promise
    public func tap<A>(on queue: DispatchQueue = .main, _ handler: @escaping (Result) throws -> Promise<A>) -> Promise<Result> {
        return then(on: queue) { result in
            try handler(result).then(on: queue) { _ in
                Promise(resolve: result)
            }
        }
    }

    /// Perform an operation in the middle of a promise chain that does not effect the resolved value
    ///
    /// - parameter queue:   dispatch queue to run the handler on
    /// - parameter handler: block to run in the middle of the promise chain
    ///
    /// - returns: Promise that resolves to the result of the previous Promise
    @discardableResult public func tap(on queue: DispatchQueue = .main, _ handler: @escaping (Result) throws -> Void) -> Promise<Result> {
        return tap(on: queue) {
            try Promise<Void>(resolve: handler($0))
        }
    }
}
