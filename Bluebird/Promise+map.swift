//
//  Promise+map.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    /// Map an array of items to Promises, and resolve when all Promises resolve. Rejects as soon as any Promise rejects.
    ///
    /// - parameter items:     items to map
    /// - parameter transform: transform function run on each item
    ///
    /// - returns: Promise
    public static func map<A, B>(_ items: [A], _ transform: (A) throws -> Promise<B>) -> Promise<[B]> {
        do {
            return all(try items.map { try transform($0) })
        } catch {
            return Promise<[B]>(reject: error)
        }
    }
}
