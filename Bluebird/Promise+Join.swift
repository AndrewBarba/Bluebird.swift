//
//  Promise+Join.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    public static func join<A, B, C, D, E>(_ a: Promise<A>, _ b: Promise<B>, _ c: Promise<C>, _ d: Promise<D>, _ e: Promise<E>) -> Promise<(A, B, C, D, E)> {
        return Promise<(A, B, C, D, E)> { resolve, reject in

            var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?

            let queue = DispatchQueue(label: "com.abarba.Bluebird.join")

            let check = {
                guard let _a = _a, let _b = _b, let _c = _c, let _d = _d, let _e = _e else { return }
                resolve((_a, _b, _c, _d, _e))
            }

            a.addHandlers(queue: queue, { _a = $0; check() }, reject)
            b.addHandlers(queue: queue, { _b = $0; check() }, reject)
            c.addHandlers(queue: queue, { _c = $0; check() }, reject)
            d.addHandlers(queue: queue, { _d = $0; check() }, reject)
            e.addHandlers(queue: queue, { _e = $0; check() }, reject)
        }
    }

    public static func join<A, B, C, D>(_ a: Promise<A>, _ b: Promise<B>, _ c: Promise<C>, _ d: Promise<D>) -> Promise<(A, B, C, D)> {
        return join(a, b, c, d, Void()).then {
            Promise<(A, B, C, D)>(resolve: ($0.0, $0.1, $0.2, $0.3))
        }
    }

    public static func join<A, B, C>(_ a: Promise<A>, _ b: Promise<B>, _ c: Promise<C>) -> Promise<(A, B, C)> {
        return join(a, b, c, Void(), Void()).then {
            Promise<(A, B, C)>(resolve: ($0.0, $0.1, $0.2))
        }
    }

    public static func join<A, B>(_ a: Promise<A>, _ b: Promise<B>) -> Promise<(A, B)> {
        return join(a, b, Void(), Void(), Void()).then {
            Promise<(A, B)>(resolve: ($0.0, $0.1))
        }
    }
}
