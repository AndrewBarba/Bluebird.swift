//
//  Promise+try.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/4/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Begin a promise chain
///
/// - parameter queue:   dispatch queue to start the chain on
/// - parameter handler: handler to run
///
/// - returns: Promise
public func `try`<A>(on queue: DispatchQueue = .main, _ handler: @escaping () throws -> Promise<A>) -> Promise<A> {
    return VoidPromise().then(on: queue) {
        try handler()
    }
}

/// Begin a promise chain
///
/// - parameter queue:   dispatch queue to start the chain on
/// - parameter handler: handler to run
///
/// - returns: Promise
public func `try`<A>(on queue: DispatchQueue = .main, _ handler: @escaping () throws -> A) -> Promise<A> {
    return Bluebird.try(on: queue) {
        Promise<A>(resolve: try handler())
    }
}
