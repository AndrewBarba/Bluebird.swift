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
            addHandlers(on: queue, { _ in }, {
                do {
                    try handler($0).addHandlers(resolve, reject)
                } catch {
                    return reject(error)
                }
            })
        }
    }

    @discardableResult
    public func `catch`(on queue: DispatchQueue = .main, _ handler: @escaping (Error) throws -> Void) -> Promise<Void> {
        return self.catch(on: queue) {
            try Promise<Void>(resolve: handler($0))
        }
    }
}
