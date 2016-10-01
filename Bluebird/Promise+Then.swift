//
//  Promise+Then.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    public func then<A>(queue: DispatchQueue = .main, _ handler: @escaping (Result) throws -> Promise<A>) -> Promise<A> {
        return Promise<A> { resolve, reject in
            addHandlers(queue: queue, {
                do {
                    try handler($0).addHandlers(resolve, reject)
                } catch {
                    return reject(error)
                }
            }, {
                reject($0)
            })
        }
    }

    @discardableResult
    public func then(queue: DispatchQueue = .main, _ handler: @escaping (Result) throws -> Void) -> Promise<Void>{
        return self.then(queue: queue) {
            try Promise<Void>(resolve: handler($0))
        }
    }
}
