//
//  Promise+Tap.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    public func tap<A>(on queue: DispatchQueue = .main, _ handler: @escaping (Result) throws -> Promise<A>) -> Promise<Result> {
        return then(on: queue) { result in
            try handler(result).then(on: queue) { _ in
                Promise(resolve: result)
            }
        }
    }

    @discardableResult
    public func tap(on queue: DispatchQueue = .main, _ handler: @escaping (Result) throws -> Void) -> Promise<Result> {
        return tap(on: queue) {
            try Promise<Void>(resolve: handler($0))
        }
    }
}
