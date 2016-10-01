//
//  Promise+Finally.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    @discardableResult
    public func finally(queue: DispatchQueue = .main, _ handler: @escaping () throws -> Void) -> Promise<Result> {
        return Promise<Result> { resolve, reject in
            addHandlers(on: queue, {
                do {
                    try handler()
                    resolve($0)
                } catch {
                    reject(error)
                }
            }, {
                do {
                    try handler()
                    reject($0)
                } catch {
                    reject(error)
                }
            })
        }
    }
}
