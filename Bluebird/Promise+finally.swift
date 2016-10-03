//
//  Promise+Finally.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    /// Always run a handler at the end of a promise chain regardless of the whether the chain resolves or rejects
    ///
    /// - parameter queue:   dispatch queue to run the handler on
    /// - parameter handler: block to run at the end of the promise chain
    ///
    /// - returns: Promise
    @discardableResult
    public func finally(queue: DispatchQueue = .main, _ handler: @escaping () throws -> Void) -> Promise<Result> {
        return Promise<Result> { resolve, reject in
            addHandler(on: queue, {
                do {
                    try handler()
                    resolve($0)
                } catch {
                    reject(error)
                }
            }, {
                do {
                    try handler()
                    reject($0)
                } catch {
                    reject(error)
                }
            })
        }
    }
}
