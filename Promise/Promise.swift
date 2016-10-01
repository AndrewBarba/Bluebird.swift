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

    fileprivate var resolvedHandler: ((Result) -> Void)?

    fileprivate var rejectedHandler: ((Error) -> Void)?

    /**
     Current state of the promise
     */
    public private(set) var state: State<Result>

    /**
     Initialize to a resolved promise
     */
    public init(result: Result) {
        self.state = .resolved(result)
    }

    /**
     Initialize to a rejected promise
     */
    public init(error: Error) {
        self.state = .rejected(error)
    }

    /**
     Initialize with a resolver function
     */
    public init(_ resolver: (@escaping (Result) -> Void, @escaping (Error) -> Void) throws -> Void) {
        self.state = .pending
        do {
            try resolver({
                self.setSynchronous(state: .resolved($0))
            }, {
                self.setSynchronous(state: .rejected($0))
            })
        } catch {
            setSynchronous(state: .rejected(error))
        }
    }

    /**
     Initialize with a resolver promise function
     */
    public convenience init(_ resolver: () throws -> Promise<Result>) {
        self.init { resolve, reject in
            try resolver().then(resolve).catch(reject)
        }
    }

    /**
     Always resolve on the main thread
     */
    private func setSynchronous(state: State<Result>) {
        DispatchQueue.main.async {
            switch self.state {
            case .pending:
                self.state = state
                self.handleStateChanged()
            default:
                break
            }
        }
    }

    /**
     Trigger resolve functions
     */
    private func handleStateChanged() {
        switch state {
        case .pending:
            break
        case .resolved(let result):
            resolvedHandler?(result)
        case .rejected(let error):
            rejectedHandler?(error)
        }
    }
}

// MARK: - Then

extension Promise {

    @discardableResult
    public func then<A>(_ handler: @escaping (Result) throws -> Promise<A>) -> Promise<A> {
        switch state {
        case .resolved(let result):
            do {
                return try handler(result)
            } catch {
                return Promise<A>(error: error)
            }
        case .rejected(let error):
            return Promise<A>(error: error)
        case .pending:
            return Promise<A> { resolve, reject in
                resolvedHandler = {
                    do {
                        try handler($0).then(resolve).catch(reject)
                    } catch {
                        reject(error)
                    }
                }
                rejectedHandler = { reject($0) }
            }
        }
    }

    @discardableResult
    public func then(_ handler: @escaping (Result) throws -> Void) -> Promise<Void>{
        return self.then {
            return try Promise<Void>(result: handler($0))
        }
    }
}

// MARK: - Tap

extension Promise {

    @discardableResult
    public func tap<A>(_ handler: @escaping (Result) throws -> Promise<A>) -> Promise<Result> {
        return self.then { result in
            return try handler(result).then { _ in Promise(result: result) }
        }
    }

    @discardableResult
    public func tap(_ handler: @escaping (Result) throws -> Void) -> Promise<Result> {
        return self.tap {
            return try Promise<Void>(result: handler($0))
        }
    }
}

// MARK: - Catch

extension Promise {

    @discardableResult
    public func `catch`<A>(_ handler: @escaping (Error) throws -> Promise<A>) -> Promise<A> {
        switch state {
        case .resolved(_):
            return Promise<A> { _, _ in }
        case .rejected(let error):
            do {
                return try handler(error)
            } catch {
                return Promise<A>(error: error)
            }
        case .pending:
            return Promise<A> { resolve, reject in
                rejectedHandler = {
                    do {
                        try handler($0).then(resolve).catch(reject)
                    } catch {
                        reject(error)
                    }
                }
            }
        }
    }

    @discardableResult
    public func `catch`(_ handler: @escaping (Error) throws -> Void) -> Promise<Void> {
        return self.catch {
            return try Promise<Void>(result: handler($0))
        }
    }
}
