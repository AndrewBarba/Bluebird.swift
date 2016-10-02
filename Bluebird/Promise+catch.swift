//
//  Promise+Catch.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    public func `catch`<A>(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> Promise<A>) -> Promise<A> {
        return Promise<A> { resolve, reject in
            addHandler(on: queue, reject: {
                do {
                    try handler($0).addHandler(resolve, reject)
                } catch {
                    return reject(error)
                }
            })
        }
    }

    public func `catch`<A>(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> A) -> Promise<A> {
        return self.catch(on: queue) {
            try Promise<A>(resolve: handler($0))
        }
    }

    @discardableResult
    public func `catch`(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> Void) -> Promise<Void> {
        return self.catch(on: queue) {
            try Promise<Void>(resolve: handler($0))
        }
    }
}
