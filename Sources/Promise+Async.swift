//
//  Promise+Async.swift
//  
//
//  Created by Andrew Barba on 6/8/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension Promise {

    /// Retrieve the value of the promise using async/await in Swift 5.5
    ///
    /// - Returns: Result
    public func value(on queue: DispatchQueue = .main) async throws -> Result {
        return try await withCheckedThrowingContinuation { promise in
            self
                .then(on: queue) {
                    promise.resume(returning: $0)
                }
                .catch(on: queue) {
                    promise.resume(throwing: $0)
                }
        }
    }


    /// Initialize a promise with an async handler
    /// 
    /// - Parameter resolver: Async resolver
    public convenience init(_ resolver: @escaping () async throws -> Result) {
        self.init { resolve, reject in
            async {
                do {
                    let value = try await resolver()
                    resolve(value)
                } catch {
                    reject(error)
                }
            }
        }
    }


    /// Continue a promise with the value of an async handler
    ///
    /// - Returns: Promise
    public func then<A>(on queue: DispatchQueue = .main, _ handler: @escaping (Result) async throws -> A) -> Promise<A> {
        return then(on: queue) { result in
            return Promise<A> {
                return try await handler(result)
            }
        }
    }
}
