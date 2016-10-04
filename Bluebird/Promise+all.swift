//
//  Promise+All.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Returns a Promise that resolved when all passed in Promises resolve. Rejects as soon as one promise rejects.
///
/// - parameter queue:    dispatch queue to run the handler on
/// - parameter promises: comma separated list of Promises to resolve
///
/// - returns: Promise
public func all<A>(on queue: DispatchQueue = .main, _ promises: Promise<A>...) -> Promise<[A]> {
    return all(on: queue, promises)
}

/// Returns a Promise that resolved when all passed in Promises resolve. Rejects as soon as one promise rejects.
///
/// - parameter queue:    dispatch queue to run the handler on
/// - parameter promises: array of Promises to resolve
///
/// - returns: Promise
public func all<A>(on queue: DispatchQueue = .main, _ promises: [Promise<A>]) -> Promise<[A]> {
    guard promises.count > 0 else { return Promise<[A]>(resolve: []) }

    return Promise<[A]> { resolve, reject in

        var remaining = promises.count

        let queue = DispatchQueue(label: "com.abarba.Bluebird.all")

        let check: (A) -> () = { _ in
            remaining -= 1
            guard remaining == 0 else { return }
            queue.async {
                resolve(promises.map { $0.result! })
            }
        }

        promises.forEach {
            $0.addHandlers([
                .resolve(queue, check),
                .reject(queue, reject)
            ])
        }
    }
}
