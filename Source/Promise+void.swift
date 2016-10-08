//
//  Promise+Void.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    /// Converts the current Promise to a generic Void Promise
    public var asVoid: Promise<Void> {
        return then { _ in () }
    }
}

/// Convenient function for creating a resolved Void Promise
///
/// - returns: Promise
public func VoidPromise() -> Promise<Void> {
    return Promise<Void>(resolve: ())
}
