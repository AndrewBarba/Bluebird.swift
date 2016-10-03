//
//  Promise+race.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Returns a Promise that resolves as soon as one passed in Promise resolves
///
/// - parameter promises: comma separated list of Promises to resolve
///
/// - returns: Promise that resolves to first resolved Promise
public func any<A>(_ promises: Promise<A>...) -> Promise<A> {
    return any(promises)
}

/// Returns a Promise that resolves as soon as one passed in Promise resolves
///
/// - parameter promises: array of Promises to resolve
///
/// - returns: Promise that resolves to first resolved Promise
public func any<A>(_ promises: [Promise<A>]) -> Promise<A> {
    guard promises.count > 0 else {
        return Promise<A>(reject: BluebirdError.rangeError)
    }

    return Promise<A> { resolve, reject in
        promises.forEach {
            $0.addHandlers([
                .resolve(.main, resolve),
                .reject(.main, reject)
            ])
        }
    }
}
