//
//  File.swift
//  
//
//  Created by Andrew Barba on 1/7/20.
//

#if canImport(Combine)
import Combine
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Promise {


    /// Returns a Combine publisher
    /// 
    /// - Parameter queue: dispatch queue to run the handler on
    public func publisher(on queue: DispatchQueue = .main) -> AnyPublisher<Result, Error> {
        return Future<Result, Error> { resolve in
            self.addHandlers([
                .resolve(queue, { resolve(.success($0)) }),
                .reject(queue, { resolve(.failure($0)) }),
                .cancel(queue, { resolve(.failure(BluebirdError.cancelled)) })
            ])
        }.eraseToAnyPublisher()
    }
}
#endif
