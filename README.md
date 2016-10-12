Bluebird.swift
==============

[![Build Status](https://www.bitrise.io/app/701ab7c9f38d6256.svg?token=iG7jwI_9wFXyDl886lLAWw&branch=master)](https://www.bitrise.io/app/701ab7c9f38d6256)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Bluebird.svg)](https://img.shields.io/cocoapods/v/Bluebird.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
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

- iOS 9.0+ / macOS 10.11+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.0+
- Swift 3.0+

## Installation

### CocoaPods

> CocoaPods 1.1.0+ is required to build Bluebird

```ruby
pod 'Bluebird', '~> 1.9'
```

### Carthage

```ogdl
github "AndrewBarba/Bluebird.swift" ~> 1.9
```

## Who's Using Bluebird

- [Tablelist](https://itunes.apple.com/us/app/tablelist-a-better-night-out/id634444177)

> Using Bluebird in production? Let me know with a Pull Request or an Issue.

## Usage

- [Promise](#promise)
- [then](#then)
- [catch](#catch)
- [tap](#tap)
- [finally](#finally)
- [join](#join)
- [map](#map)
- [reduce](#reduce)
- [all](#all)
- [any](#any)
- [try](#try)

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

```swift
authService.login(email: email, password: password)
  .then { auth in userService.read(with: auth) }
  .then { user in favoriteService.list(for: user) }
  .then { favorites in ... }
```

Notice each time you return a Promise (or a value) from a `then` handler, the next `then` handler receives the resolution of that handler, waiting for the previous to fully resolve. This is extremely powerful for asynchronous control flow.

#### Grand Central Dispatch

Any method in `Bluebird` that accepts a handler also accepts a `DispatchQueue` so you can control what queue you want the handler to run on:

```swift
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

By default all handlers are run on the `.main` queue.

### catch

Use `catch` to handle / recover from errors that happen in a Promise chain:

```swift
authService.login(email: email, password: password)
  .then { auth in userService.read(with: auth) }
  .then { user in favoriteService.list(for: user) }
  .then { favorites in ... }
  .catch { error in
    self.present(error: error)
  }
```

Above, if any `then` handler `throw`s an error, or if one of the Promises returned from a handler rejects, then the final catch handler will be called.

You can also perform complex recovery when running multiple asynchronous operations:

```swift
Bluebird.try { performFirstOp().catch(handleOpError) }
  .then { performSecondOp().catch(handleOpError) }
  .then { performThirdOp().catch(handleOpError) }
  .then { performFourthOp().catch(handleOpError) }
  .then {
    // all completed
  }
```

### tap

Useful for performing an operation in the middle of a promise chain without changing the type of the Promise:

```swift
authService.login(email: email, password: password)
  .tap { auth in print(auth) }
  .then { auth in userService.read(with: auth) }
  .tap { user in print(user) }
  .then { user in favoriteService.list(for: user) }
  .then { favorites in ... }
```

You can also return a Promise from the `tap` handler and the chain will wait for that promise to resolve:

```swift
authService.login(email: email, password: password)
  .then { auth in userService.read(with: auth) }
  .tap { user in userService.updateLastActive(for: user) }
  .then { user in favoriteService.list(for: user) }
  .then { favorites in ... }
```

### finally

With `finally` you can register a handler to run at the end of a Promise chain, regardless of it's result:

```swift
spinner.startAnimating()

authService.login(email: email, password: "bad password")
  .then { auth in userService.read(with: auth) } // will not run
  .then { user in favoriteService.list(for: user) } // will not run
  .finally { // this will run!
    spinner.stopAnimating()
  }
  .catch { error in
    // handle error
  }
```

### join

Join different types of Promises seamlessly:

```swift
join(fetchArticle(id: "123"), fetchAuthor(id: "456"))
  .then { article, author in
    // ...
  }
```

### map

Iterate over a sequence of elements and perform an operation each:

```swift
let articles = ...

map(articles) { article in
  return favoriteService.like(article: article)
}.then { _ in
  // all articles liked successfully
}.catch { error in
  // handle error
}
```

You can also iterate over a sequence in series using `mapSeries()`.

### reduce

Iterate over a sequence and reduce down to a Promise that resolves to a single value:

```swift
let users = ...

reduce(users, 0) { partialTime, user in
  return userService.getActiveTime(for: user).then { time in
    return partialTime + time
  }
}.then { totalTime in
  // calculated total time spent in app
}.catch { error in
  // handle error
}
```

### all

Wait for all promises to complete:

```swift
all([
  favoriteService.like(article: article1),
  favoriteService.like(article: article2),
  favoriteService.like(article: article3),
  favoriteService.like(article: article4),
]).then { _ in
  // all articles liked
}
```

### any

Easily handle race conditions with `any`, as soon as one Promise resolves the handler is called and will never be called again:

```swift
let host1 = "https://east.us.com/file"
let host2 = "https://west.us.com/file"

any(download(host1), download(host2))
  .then { data in
    ...
  }
```

### try

Start off a Promise chain:

```swift
// Prefix with Bluebird since try is reserved in Swift
Bluebird.try {
  authService.login(email: email, password: password)
}.then { auth in
  // handle login
}.catch { error in
  // handle error
}
```

## Tests

Tests are continuously run on [Bitrise](https://www.bitrise.io/). Since Bitrise doesn't support public test runs I can't link to them, but you can run the tests yourself by opening the Xcode project and running the tests manually from the Bluebird scheme.

## Bluebird vs PromiseKit

I'd be lying if I said [PromiseKit](https://github.com/mxcl/PromiseKit) wasn't a fantastic library (it is!) but Bluebird has different goals that may or may not appeal to different developers.

#### Xcode 8+ / Swift 3+

PromiseKit goes to great length to maintain compatibility with Objective-C, previous versions of Swift, and previous versions of Xcode. Thats a ton of work, god bless them.

#### Generics & Composition

Bluebird has a more sophisticated use of generics throughout the library giving us really nice API for composing Promise chains in Swift.

Bluebird supports `map`, `reduce`, `all`, `any` with any Sequence type, not just arrays. For example, you could use [Realm's](https://realm.io/docs/swift/latest/) `List` or `Result` types in all of those functions, you can't do this with PromiseKit.

Bluebird also supports `Promise.map` and `Promise.reduce` (same as Bluebird.js) which act just like their global equivalent, but can be chained inline on an existing Promise, greatly enhancing Promise composition.

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

```swift
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
