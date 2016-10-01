//
//  Promise.swift
//  Promise
//
//  Created by Andrew Barba on 9/30/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

public enum State<T> {
    case pending
    case resolved(_: T)
    case rejected(_: Error)
}

public final class Promise<Result> {

    private var resolvedHandlers: [(queue: DispatchQueue, handler: (Result) -> Void)] = []

    private var rejectedHandlers: [(queue: DispatchQueue, handler: (Error) -> Void)] = []

    private let stateQueue = DispatchQueue(label: "com.abarba.Bluebird.state")

    /**
     Current state of the promise
     */
    public private(set) var state: State<Result>

    /**
     The resolved result of this promise
     */
    public var result: Result? {
        switch state {
        case .resolved(let result):
            return result
        default:
            return nil
        }
    }

    /**
     The resolved error of this promise
     */
    public var error: Error? {
        switch state {
        case .rejected(let error):
            return error
        default:
            return nil
        }
    }

    /**
     Initialize to a resolved promise
     */
    public init(resolve result: Result) {
        self.state = .resolved(result)
    }

    /**
     Initialize to a rejected promise
     */
    public init(reject error: Error) {
        self.state = .rejected(error)
    }

    /**
     Initialize with a resolver function
     */
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

    /**
     Initialize with a resolver promise function
     */
    public convenience init(_ resolver: () throws -> Promise<Result>) {
        self.init { resolve, reject in
            try resolver().addHandlers(resolve, reject)
        }
    }

    private func set(state: State<Result>) {
        stateQueue.async {
            switch self.state {
            case .pending:
                self.state = state
                self.handleStateChanged()
            default:
                break
            }
        }
    }

    private func handleStateChanged() {
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

    @discardableResult
    internal func addHandlers(on queue: DispatchQueue = .main, _ resolve: @escaping (Result) -> Void, _ reject: @escaping (Error) -> Void) -> Promise<Result> {
        stateQueue.async {
            switch self.state {
            case .pending:
                self.resolvedHandlers.append((queue, resolve))
                self.rejectedHandlers.append((queue, reject))
            case .resolved(let result):
                queue.async { resolve(result) }
            case .rejected(let error):
                queue.async { reject(error) }
            }
        }
        return self
    }
}
