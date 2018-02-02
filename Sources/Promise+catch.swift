//
//  Promise+Catch.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

import Foundation

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
}
