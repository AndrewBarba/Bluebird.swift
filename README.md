Bluebird.swift
==============

[![Build Status](https://www.bitrise.io/app/701ab7c9f38d6256.svg?token=iG7jwI_9wFXyDl886lLAWw&branch=master)](https://www.bitrise.io/app/701ab7c9f38d6256)

Promise/A+, [Bluebird](https://github.com/petkaantonov/bluebird/) inspired, implementation in Swift 3

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
  // ...
  // - resolve(someInt)
  // - reject(someError)
  // ...
}
```

The `resolve` and `reject` functions can be called asynchronously or synchronously. This is a great way to wrap existing Cocoa API to resolve Promises in your own code. For example, say we have an expensive function that manipulates an image:

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

Okay, so the inner body of the function looks almost identical, aside from the fact that in the Promise implementation we are returning *something*. But look at how much better the function signature looks! Notice no more completion handler, no more optional image in the completion handler, and no more optional error in the completion handler. Those optional in the original function are a dead giveaway that you will be doing a bunch of checks later on unwrap them and act accordingly. But with the Promise implementation that logic is all hidden in the magic of Promises. Using this new function is now a joy:

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

> In progress...

### catch

> In progress...

### tap

> In progress...

### finally

> In progress...
