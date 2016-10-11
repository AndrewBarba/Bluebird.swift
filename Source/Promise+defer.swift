//
//  Promise+defer.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/11/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    /// Wrap a Promise and its resolve / reject handlers in a tuple
    public typealias Resolver = (promise: Promise<Result>, resolve: (Result) -> Void, reject: (Error) -> Void)

    /// Useful for resolving a Promise outside of the default constructors
    ///
    /// - returns: Resolver
    public static func `defer`() -> Resolver {
        var resolve: ((Result) -> Void)!
        var reject: ((Error) -> Void)!
        let promise = Promise<Result> {
            resolve = $0
            reject = $1
        }
        return (promise, resolve, reject)
    }
}
