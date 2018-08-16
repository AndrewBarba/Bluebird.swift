//
//  Promise.swift
//  Promise
//
//  Created by Andrew Barba on 9/30/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

import Foundation

/// Enum representing the current state of a Promise
///
/// - pending:  in a pending state, neither resolved or rejected
/// - resolved: resolved. the promise can never change to another state
/// - rejected: rejected. the promise can never change to another state
internal enum State<T> {
    case pending(_: [StateHandler<T>])
    case resolved(_: T)
    case rejected(_: Error)
    case canceled
    
    /// Is this a pending state
    public var isPending: Bool {
        switch self {
        case .pending:
            return true
        default:
            return false
        }
    }

    /// Is this promise canceled
    public var isCanceled: Bool {
        switch self {
        case .canceled:
            return true
        default:
            return false
        }
    }
    
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

/// Handler function to be called when a Promise changes state
///
/// - resolve: block to be called if Promise resolves
/// - reject:  block to be called if Promise rejects
internal enum StateHandler<T> {
    case resolve(_: DispatchQueue, _: (T) -> Void)
    case reject(_: DispatchQueue, _: (Error) -> Void)
    case cancel(_: DispatchQueue, _: () -> Void)
}

public final class Promise<Result> {
    
    /// Private lock for performing state related operations
    private let lock = Lock()
    
    /// The current state of the promise
    internal private(set) var state: State<Result>
    
    /// Is this Promise in a pending state
    public var isPending: Bool {
        return lock.sync { state.isPending }
    }

    /// Is this Promise in a canceled state
    public var isCanceled: Bool {
        return lock.sync { state.isCanceled }
    }
    
    /// The resolved result of the promise
    public var result: Result? {
        return lock.sync { state.result }
    }
    
    /// The rejected error of the promise
    public var error: Error? {
        return lock.sync { state.error }
    }
    
    /// Initialize to a resolved result
    ///
    /// - parameter result: the final result of the promise
    ///
    /// - returns: Promise
    public init(resolve result: Result) {
        self.state = .resolved(result)
    }
    
    /// Initializa to a rejected error
    ///
    /// - parameter error: the final error of the promise
    ///
    /// - returns: Promise
    public init(reject error: Error) {
        self.state = .rejected(error)
    }
    
    /// Initialize using a resolver function
    ///
    /// - parameter resolver: takes in two blocks, one to resolve and one to reject the promise. Can be called synchronously or asynchronously
    ///
    /// - returns: Promise
    public init(_ resolver: (@escaping (Result) -> Void, @escaping (Error) -> Void) throws -> Void) {
        self.state = .pending([])
        do {
            try resolver(
                { self.set(state: .resolved($0)) },
                { self.set(state: .rejected($0)) }
            )
        } catch {
            set(state: .rejected(error))
        }
    }

    /// Initialize using a resolver function and onCancel block
    ///
    /// - parameter resolver: takes in three blocks: one to resolve, one to reject, and one to run when cancelled. onCancel block must be called synchronously, and you pass in a DispatchQueue to run the block on as the first argument
    ///
    /// - returns: Promise
    public init(_ resolver: (@escaping (Result) -> Void, @escaping (Error) -> Void, (DispatchQueue, @escaping () -> Void) -> Void) throws -> Void) {
        self.state = .pending([])
        do {
            try resolver(
                { self.set(state: .resolved($0)) },
                { self.set(state: .rejected($0)) },
                { addHandlers([.cancel($0, $1)]) }
            )
        } catch {
            set(state: .rejected(error))
        }
    }
    
    /// Convenience initializer to resolve this Promise when a returned Promise is resolved
    ///
    /// - parameter resolver: block that returns a Promise that this Promise will resolve to
    ///
    /// - returns: Promise
    public convenience init(_ resolver: () throws -> Promise<Result>) {
        self.init { resolve, reject in
            try resolver().addHandlers([
                .resolve(.main, resolve),
                .reject(.main, reject)
            ])
        }
    }

    /// Cancels the promise synchronously
    ///
    /// - Returns: Promise
    @discardableResult
    public func cancel() -> Promise<Result> {
        set(state: .canceled)
        return self
    }
    
    /// Safely set the state of this Promise
    ///
    /// - parameter state: the new state of the Promise
    private func set(state newState: State<Result>) {
        lock.sync {
            guard case .pending(let handlers) = state else { return }
            
            state = newState
            
            handlers.forEach { handler in
                switch (state, handler) {
                case (.resolved(let result), .resolve(let queue, let block)):
                    queue.async { block(result) }
                case (.rejected(let error), .reject(let queue, let block)):
                    queue.async { block(error) }
                case (.canceled, .cancel(let queue, let block)):
                    queue.async { block() }
                default:
                    break
                }
            }
        }
    }
    
    /// Adds handlers that will be run when this Promise resolves or rejects
    ///
    /// - parameter queue:   the dispatch queue to run the passed in handlers on
    /// - parameter resolve: a block to run when the Promise resolves
    /// - parameter reject:  a block to run when the Promise rejects
    ///
    /// - returns: Self
    @discardableResult internal func addHandlers(_ handlers: [StateHandler<Result>]) -> Promise<Result> {
        return lock.sync {
            switch state {
            case .pending(let currentHandlers):
                state = .pending(currentHandlers + handlers)
            case .resolved(let result):
                handlers.forEach { runHandler($0, with: result) }
            case .rejected(let error):
                handlers.forEach { runHandler($0, with: error) }
            case .canceled:
                break
            }
            return self
        }
    }
    
    /// Runs a handler if it is a resolve handler
    ///
    /// - parameter handler: handler to run
    /// - parameter result:  resolved result
    private func runHandler(_ handler: StateHandler<Result>, with result: Result) {
        switch handler {
        case .resolve(let queue, let block):
            queue.async { block(result) }
        default:
            break
        }
    }
    
    /// Runs a handler if it is a reject handler
    ///
    /// - parameter handler: handler to run
    /// - parameter error:   resolved error
    private func runHandler(_ handler: StateHandler<Result>, with error: Error) {
        switch handler {
        case .reject(let queue, let block):
            queue.async { block(error) }
        default:
            break
        }
    }
}
