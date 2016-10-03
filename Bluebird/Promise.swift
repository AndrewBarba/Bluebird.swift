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

/// Handler function to be called when a Promise changes state
///
/// - resolve: block to be called if Promise resolves
/// - reject:  block to be called if Promise rejects
internal enum StateHandler<T> {
    case resolve(_: DispatchQueue, _: (T) -> ())
    case reject(_: DispatchQueue, _: (Error) -> ())
}

public final class Promise<Result> {

    /// Handlers to be called when the promise changes state
    private var stateHandlers: [StateHandler<Result>] = []

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
            try resolver().addHandlers([
                .resolve(.main, resolve),
                .reject(.main, reject)
            ])
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
        defer { stateHandlers = [] }

        stateHandlers.forEach { handler in
            switch (state, handler) {
            case (.pending, _):
                break
            case (.resolved(let result), .resolve(let queue, let block)):
                queue.async { block(result) }
            case (.rejected(let error), .reject(let queue, let block)):
                queue.async { block(error) }
            default:
                break
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
    internal func addHandlers(_ handlers: [StateHandler<Result>]) -> Promise<Result> {
        performStateOperation { current in
            switch current {
            case .pending:
                stateHandlers.append(contentsOf: handlers)
            case .resolved(let result):
                handlers.forEach { runHandler($0, with: result) }
            case .rejected(let error):
                handlers.forEach { runHandler($0, with: error) }
            }
        }
        return self
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
