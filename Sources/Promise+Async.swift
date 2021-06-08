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
    public func value() async throws -> Result {
        return try await withUnsafeThrowingContinuation { promise in
            self
                .then { promise.resume(returning: $0) }
                .catch { promise.resume(throwing: $0) }
        }
    }
}
