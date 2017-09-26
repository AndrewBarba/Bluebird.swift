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
    @discardableResult public func finally(on queue: DispatchQueue = .main, _ handler: @escaping () throws -> Void) -> Promise<Result> {
        return Promise<Result> { resolve, reject in
            addHandlers([
                .resolve(queue, {
                    do {
                        try handler()
                        resolve($0)
                    } catch {
                        reject(error)
                    }
                }),
                .reject(queue, {
                    do {
                        try handler()
                        reject($0)
                    } catch {
                        reject(error)
                    }
                })
            ])
        }
    }
}
