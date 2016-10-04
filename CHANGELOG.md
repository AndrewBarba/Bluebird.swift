Change Log
==========

`Bluebird.swift` follows [Semantic Versioning](http://semver.org/)

---

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
