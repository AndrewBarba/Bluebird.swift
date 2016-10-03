//
//  Promise.swift
//  Promise
//
//  Created by Andrew Barba on 9/30/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Enum representing the current state of a Promise
///
/// - pending:  in a pending state, neither resolved or rejected
/// - resolved: resolved. the promise can never change to another state
/// - rejected: rejected. the promise can never change to another state
public enum State<T> {
    case pending
    case resolved(_: T)
    case rejected(_: Error)
}

public final class Promise<Result> {

    /// Handlers to be called when the promise resolved
    private var resolvedHandlers: [(queue: DispatchQueue, handler: (Result) -> Void)] = []


    /// Handlers to be called when the promise is rejected
    private var rejectedHandlers: [(queue: DispatchQueue, handler: (Error) -> Void)] = []

    /// Private dispatch queue for performing state related operations
    private let stateQueue = DispatchQueue(label: "com.abarba.Bluebird.state")


    /// The current state of the promise
    public private(set) var state: State<Result> {
        didSet {
            handleStateChanged()
        }
    }

    /// The resolved result of the promise
    public var result: Result? {
        switch state {
        case .resolved(let result):
            return result
        default:
            return nil
        }
    }

    /// The rejected error of the promise
    public var error: Error? {
        switch state {
        case .rejected(let error):
            return error
        default:
            return nil
        }
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
    /// - parameter resolver: takes in a two blocks, one to resolve and one to reject the promise. Can be called synchronously or asynchronously
    ///
    /// - returns: Promise
    public init(_ resolver: (@escaping (Result) -> Void, @escaping (Error) -> Void) throws -> Void) {
        self.state = .pending
        do {
            try resolver({
                self.set(state: .resolved($0))
            }, {
                self.set(state: .rejected($0))
            })
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
            try resolver().addHandler(resolve, reject)
        }
    }

    /// Safely perform an operation on the Promise's state
    ///
    /// - parameter operation: block to safely execute
    private func performStateOperation(_ operation: (State<Result>) -> ()) {
        stateQueue.sync {
            operation(state)
        }
    }

    /// Safely set the state of this Promise
    ///
    /// - parameter state: the new state of the Promise
    private func set(state: State<Result>) {
        performStateOperation { current in
            switch current {
            case .pending:
                self.state = state
            default:
                break
            }
        }
    }

    /// Runs the resolve/reject handlers according to Promise state. Clears handlers after execution
    private func handleStateChanged() {
        defer {
            resolvedHandlers = []
            rejectedHandlers = []
        }

        switch state {
        case .pending:
            break
        case .resolved(let result):
            resolvedHandlers.forEach { item in
                item.queue.async { item.handler(result) }
            }
        case .rejected(let error):
            rejectedHandlers.forEach { item in
                item.queue.async { item.handler(error) }
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
    @discardableResult
    internal func addHandler(on queue: DispatchQueue = .main, _ resolve: @escaping (Result) -> Void, _ reject: @escaping (Error) -> Void) -> Promise<Result> {
        performStateOperation { current in
            switch current {
            case .pending:
                resolvedHandlers.append((queue, resolve))
                rejectedHandlers.append((queue, reject))
            case .resolved(let result):
                queue.async { resolve(result) }
            case .rejected(let error):
                queue.async { reject(error) }
            }
        }
        return self
    }

    /// Adds a handler that will be run when this Promise resolves
    ///
    /// - parameter queue:   the dispatch queue to run the passed in handler on
    /// - parameter resolve: a block to run when the Promise resolves
    ///
    /// - returns: Self
    @discardableResult
    internal func addHandler(on queue: DispatchQueue = .main, resolve: @escaping (Result) -> Void) -> Promise<Result> {
        performStateOperation { current in
            switch current {
            case .pending:
                resolvedHandlers.append((queue, resolve))
            case .resolved(let result):
                queue.async { resolve(result) }
            case .rejected(_):
                break
            }
        }
        return self
    }

    /// Adds a handler that will be run when this Promise rejects
    ///
    /// - parameter queue:   the dispatch queue to run the passed in handler on
    /// - parameter resolve: a block to run when the Promise rejects
    ///
    /// - returns: Self
    @discardableResult
    internal func addHandler(on queue: DispatchQueue = .main, reject: @escaping (Error) -> Void) -> Promise<Result> {
        performStateOperation { current in
            switch current {
            case .pending:
                rejectedHandlers.append((queue, reject))
            case .resolved(_):
                break
            case .rejected(let error):
                queue.async { reject(error) }
            }
        }
        return self
    }
}
