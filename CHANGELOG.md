Change Log
==========

`Bluebird.swift` follows [Semantic Versioning](http://semver.org/)

---

## [5.1.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/5.1.0)

1. Support Combine framework with new `.publisher()` method

## [5.0.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/5.0.0)

1. Built with Swift 5.0

## [4.0.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/4.0.0)

1. Built with Swift 4.2

## [3.0.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/3.0.0)

1. On iOS 10+ and macOS 10.12+ the locking mechanism for `Promise` is backed by `os_unfair_lock` bringing a significant performance improvement. On prior versions of iOS and macOS the locking mechanism falls back to a serial `DispatchQueue`
2. Expose a new `Lock` class that hides the implementation detail of the underlying lock, preferring `os_unfair_lock` when available, and falling back to a serial `DispatchQueue` when it's not.

## [2.4.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/2.4.0)

1. Add `Promise.cancel`
2. Add `Promise { resolve, reject, onCancel in }`

## [2.3.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/2.3.0)

1. Bad release - see [v2.4.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/2.4.0)

## [2.2.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/2.2.0)

1. Add `Promise.tapCatch`

## [2.1.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/2.1.0)

1. Add `Promise.return`
2. Support CocoaPods v1.4.0
3. Support Swift Package Manager
4. Hosted documentation generated with Jazzy

## [2.0.1](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/2.0.1)

1. Add missing Foundation imports for Swift Package Manager

## [2.0.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/2.0.0)

1. Swift 4 and Xcode 9
2. Renamed `catchThen` to `recover`
3. Added Promise/A+ test suite

## [1.11.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.11.0)

1. Swift 3.1

## [1.10.3](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.10.3)

1. QOS on internal state queue

## [1.10.2](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.10.2)

1. Open `Promise` class

## [1.10.1](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.10.1)

1. Better state handling using the sync queue. Fixes any issues I found in Xcode 8's Thread Sanitizer.

## [1.10.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.10.0)

1. Introduce `Promise.catchThen` to recover from a rejection with another result of the same type

## [1.9.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.9.0)

1. Add `Promise.delay` for delaying the execution of a Promise chain
2. Add `Promise.timeout` to reject a Promise if it does not resolve in a given amount of time

## [1.8.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.8.0)

1. Add `Promise.reflect` for returning a Promise that will always resolve
2. Add `Promise<Type>.defer` for returning a resolver tuple that can be used to resolve a Promise outside of the default constructors

## [1.7.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.7.0)

1. Add `Promise.map` and `Promise.mapSeries`, identical to the global `map()` and `mapSeries()`, but can be chained on an existing Promise that resolves to a sequence
2. Add `Promise.reduce`, identical to the global `reduce()`, but can be chained on an existing Promise that resolves to a sequence
3. Rename `map(series:)` to `mapSeries` for API consistency

## [1.6.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.6.0)

1. Add targets for all platforms: iOS, macOS, tvOS, watchOS
2. Fix incorrect dispatch queue usage in `all`

## [1.5.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.5.0)

1. Add `reduce` function to iterate over a sequence and resolve to a single value

## [1.4.1](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.4.1)

1. Support generic sequence types in `map`, `all`, `any`, `race`

## [1.4.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.4.0)

1. Add a `(on:queue)` parameter to all functions. Defaults to `.main`
2. Add a `try` function for beginning a Promise chain

## [1.3.1](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.3.1)

1. A much cleaner, more readable implementation of `map(series:)`

## [1.3.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.3.0)

1. Map over a collection that resolves each promise in series

## [1.2.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.2.0)

1. Fixes on API inconsistency where `finally` did not have the `on` argument name

## [1.1.0](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.1.0)

1. Add full test coverage for every Promise function
2. Convert static Promise functions (all, any, join, map) to be free standing functions because we can't add static functions on a generic class...

## [1.0.2](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.0.2)

1. No API was added/changed in this release
2. 100% documented

Todo: Unit tests! Those are next, top priority.

## [1.0.1](https://github.com/AndrewBarba/Bluebird.swift/releases/tag/1.0.1)

Initial release. Full documentation can be found on [CocoaDocs](http://cocoadocs.org/docsets/Bluebird/)
