//
//  Promise+return.swift
//  Bluebird
//
//  Created by Andrew Barba on 1/19/18.
//

import Foundation

extension Promise {

    /// Convenience method for `.then { _ in value }`
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue to run the handler on
    ///   - value: Value to resolve promise to
    /// - Returns: Promise
    public func `return`<A>(on queue: DispatchQueue = .main, _ value: A) -> Promise<A> {
        return then(on: queue) { _ in value }
    }

    /// Convenience method for `.then { _ in value }`
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue to run the handler on
    ///   - value: Value to resolve promise to
    /// - Returns: Promise
    public func thenReturn<A>(on queue: DispatchQueue = .main, _ value: A) -> Promise<A> {
        return then(on: queue) { _ in value }
    }
}
