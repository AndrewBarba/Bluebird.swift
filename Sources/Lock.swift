//
//  Lock.swift
//  Bluebird
//
//  Created by Andrew Barba on 8/15/18.
//

import Foundation

public class Lock {

    /// Internal backing lock, uses os_unfair_lock if available
    private let _lock: _Lock

    public init() {
        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            _lock = UnfairLock()
        } else {
            _lock = QueueLock()
        }
    }

    public func sync<T>(execute block: () throws -> T) rethrows -> T {
        return try _lock.sync(execute: block)
    }
}

private protocol _Lock {

    func sync<T>(execute block: () throws -> T) rethrows -> T
}

private class QueueLock: _Lock {

    private let _queue = DispatchQueue(label: "com.abarba.Bluebird.lock", qos: .userInteractive)

    func sync<T>(execute block: () throws -> T) rethrows -> T {
        return try _queue.sync(execute: block)
    }
}

@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)
private class UnfairLock: _Lock {

    private var _lock = os_unfair_lock()

    func sync<T>(execute block: () throws -> T) rethrows -> T {
        os_unfair_lock_lock(&_lock); defer { os_unfair_lock_unlock(&_lock) }
        return try block()
    }
}
