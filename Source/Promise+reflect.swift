//
//  Promise+reflect.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/11/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

import Foundation

/// Enum used to describe the result of a promise
///
/// - resolved: the resolved value
/// - error: the error the promise was rejected with
public enum ReflectionState<T> {
    case resolved(_: T)
    case rejected(_: Error)
    
    /// The resolved result
    public var result: T? {
        switch self {
        case .resolved(let result):
            return result
        default:
            return nil
        }
    }
    
    /// The rejected error
    public var error: Error? {
        switch self {
        case .rejected(let error):
            return error
        default:
            return nil
        }
    }
}

extension Promise {

    /// Returns a Promise that will always resolve to the final state of the receiver
    ///
    /// - parameter queue: dispatch queue to resolve on
    ///
    /// - returns: Promise
    public func reflect(on queue: DispatchQueue = .main) -> Promise<ReflectionState<Result>> {
        return Promise<ReflectionState<Result>> { resolve, _ in
            addHandlers([
                .resolve(queue) {
                    resolve(.resolved($0))
                },
                .reject(queue) {
                    resolve(.rejected($0))
                }
            ])
        }
    }
}
