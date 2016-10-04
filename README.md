Bluebird.swift
==============

[![Build Status](https://www.bitrise.io/app/701ab7c9f38d6256.svg?token=iG7jwI_9wFXyDl886lLAWw&branch=master)](https://www.bitrise.io/app/701ab7c9f38d6256)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Bluebird.svg)](https://img.shields.io/cocoapods/v/Bluebird.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Bluebird.svg?style=flat)](http://cocoadocs.org/docsets/Bluebird)
[![Twitter](https://img.shields.io/badge/twitter-@andrew_barba-blue.svg?style=flat)](http://twitter.com/andrew_barba)

[Promise/A+](https://promisesaplus.com/) compliant, [Bluebird](http://bluebirdjs.com) inspired, implementation in Swift 3

## Features

- [x] Promise/A+ Compliant
- [x] Swift 3
- [x] Performance
- [x] Lightweight
- [x] Unit Tests
- [x] 100% Documented

## Documentation

Full documentation can be found on [CocoaDocs](http://cocoadocs.org/docsets/Bluebird/)

## Requirements

- iOS 8.0+ / macOS 10.11+ / watchOS 2.0+
- Xcode 8.0+
- Swift 3.0+

## Installation

### CocoaPods

> CocoaPods 1.1.0+ is required to build Bluebird

```ruby
pod 'Bluebird', '~> 1.0'
```


### Carthage

```ogdl
github "AndrewBarba/Bluebird.swift" ~> 1.0
```

## Usage

- [Promise](#promise)
- [then](#then)
- [catch](#catch)
- [tap](#tap)
- [finally](#finally)

### Promise

Promises are generic and allow you to specify a type that they will eventually resolve to. The preferred way to create a Promise is to pass in a closure that accepts two functions, one to be called to resolve the Promise and one to be called to reject the Promise:

```swift
let promise = Promise<Int> { resolve, reject in
  // - resolve(someInt)
  // - reject(someError)
}
```

The `resolve` and `reject` functions can be called asynchronously or synchronously. This is a great way to wrap existing Cocoa API to resolve Promises in your own code. For example, look at an expensive function that manipulates an image:

###### Before Promises

```swift
func performExpensiveOperation(onImage image: UIImage, completion: @escaping (UIImage?, Error?) -> Void) {
  DispatchQueue(label: "image.operation").async {
    do {
      let image = try ...
      completion(image, nil)
    } catch {
      completion(nil, error)
    }
  }
}
```

###### After Promises

```swift
func performExpensiveOperation(onImage image: UIImage) -> Promise<UIImage> {
  return Promise<UIImage> { resolve, reject in
    DispatchQueue(label: "image.operation").async {
      do {
        let image = try ...
        resolve(image)
      } catch {
        reject(error)
      }
    }
  }
}
```

Okay, so the inner body of the function looks almost identical... But look at how much better the function signature looks!

No more completion handler, no more optional image, no more optional error. Optionals in the original function are a dead giveaway that you'll be guarding and unwrapping in the near future. With the Promise implementation that logic is hidden by good design. Using this new function is now a joy:

```swift
let original: UIImage = ...

performExpensiveOperation(onImage: original)
  .then { newImage in
    // do something with the new image
  }
  .catch { error in
    // something went wrong, handle the error
  }
```

### then

You can easily perform a series of operations with the `then` method:

```
authService.login(email: email, password: password)
  .then { auth in userService.read(with: auth) }
  .then { user in favoriteService.list(for: user) }
  .then { favorites in ... }
```

Notice each time you return a Promise (or a value) from a `then` handler, the next `then` handler receives the resolution of that handler, waiting for the previous to fully resolve. This is extremely powerful for asynchronous control flow.

###### Grand Central Dispatch

Any method in `Bluebird` that accepts a handler also accepts a `DispatchQueue` so you can control what queue you want the handler to run on:

```
userService.read(id: "123")
  .then(on: backgroundQueue) { user -> UIImage in
    let image = UIImage(user: user)
    ... perform complex image operation ...
    return image
  }
  .then(on: .main) { image in
    self.imageView.image = image
  }
```

By default we run all resolutions on the `.main` queue.

### catch

> Examples coming soon...

### tap

> Examples coming soon...

### finally

> Examples coming soon...

## Tests

> In progress... [Promise/A+ Test Suite](https://github.com/promises-aplus/promises-tests)

## Bluebird vs PromiseKit

I'd be lying if I said [PromiseKit](https://github.com/mxcl/PromiseKit) wasn't a fantastic library (it is!) but Bluebird has different goals that may or may not appeal to different developers.

#### Xcode 8+ / Swift 3+

PromiseKit goes to great length to maintain compatibility with Objective-C, previous versions of Swift, and previous versions of Xcode. Thats a ton of work, god bless them.

#### No Extensions

PromiseKit provides many useful framework extensions that wrap core Cocoa API's in Promise style functions. I currently have no plans to provide such functionality, but if I did, it would be in a different repository so I can keep this one lean and well tested.

#### Bluebird API Compatible

I began using PromiseKit after heavily using Bluebird.js in my Node/JavaScript projects but became annoyed with the subtle API differences and a few things missing all together. Bluebird.swift attempts to closely follow the API of Bluebird.js:

###### Bluebird.js

```javascript
Promise.resolve(result)
Promise.reject(error)
promise.then(handler)
promise.catch(handler)
promise.finally(() => ...)
promise.tap(value => ...)
```

###### Bluebird.swift

```swift
Promise(resolve: result)
Promise(reject: error)
promise.then(handler)
promise.catch(handler)
promise.finally { ... }
promise.tap { value in ... }
```

###### PromiseKit

```
Promise(value: result)
Promise(error: error)
promise.then(execute: handler)
promise.catch(execute: handler)
promise.always { ... }
promise.tap { result in
  switch result {
  case .fullfilled(let value):
    ...
  case .rejected(let error):
    ...
  }
}
```

These are just a few of the differences, and Bluebird.swift is certainly missing features in Bluebird.js, but my goal is to close that gap and keep maintaining an API that much more closely matches where applicable.
