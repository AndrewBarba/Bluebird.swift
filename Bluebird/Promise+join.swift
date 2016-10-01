//
//  Promise+Join.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    public static func join<A, B>(_ a: Promise<A>, _ b: Promise<B>) -> Promise<(A, B)> {
        return all([a.asVoid, b.asVoid]).then { _ in
            return Promise<(A, B)>(resolve: (a.result!, b.result!))
        }
    }

    public static func join<A, B, C>(_ a: Promise<A>, _ b: Promise<B>, _ c: Promise<C>) -> Promise<(A, B, C)> {
        return all([a.asVoid, b.asVoid, c.asVoid]).then { _ in
            return Promise<(A, B, C)>(resolve: (a.result!, b.result!, c.result!))
        }
    }

    public static func join<A, B, C, D>(_ a: Promise<A>, _ b: Promise<B>, _ c: Promise<C>, _ d: Promise<D>) -> Promise<(A, B, C, D)> {
        return all([a.asVoid, b.asVoid, c.asVoid, d.asVoid]).then { _ in
            return Promise<(A, B, C, D)>(resolve: (a.result!, b.result!, c.result!, d.result!))
        }
    }
}
