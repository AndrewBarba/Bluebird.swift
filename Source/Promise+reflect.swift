//
//  Promise+reflect.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/11/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    /// Returns a Promise that will always resolve to the final state of the receiver
    ///
    /// - parameter queue: dispatch queue to resolve on
    ///
    /// - returns: Promise
    public func reflect(on queue: DispatchQueue = .main) -> Promise<State<Result>> {
        return Promise<State<Result>> { resolve, _ in
            addHandlers([
                .resolve(queue) {
                    resolve(.resolved($0))
                },
                .reject(queue) {
                    resolve(.rejected($0))
                }
            ])
        }
    }
}
