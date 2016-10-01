//: Playground - noun: a place where people can play

import PlaygroundSupport
import Bluebird

struct User {}

struct Event {}

struct Order {}

func getUserAsync() -> Promise<User> {
    return Promise<User> { resolve, _ in
        DispatchQueue.main.async {
            resolve(User())
        }
    }
}

func getUser() -> Promise<User> {
    return Promise(resolve: User())
}

func getUserError() -> Promise<User> {
    return Promise(reject: NSError(domain: "", code: 0, userInfo: nil))
}

func getEvent() -> Promise<Event> {
    return Promise(resolve: Event())
}

func getEventError() -> Promise<Event> {
    return Promise(reject: NSError(domain: "", code: 0, userInfo: nil))
}

func getOrder() -> Promise<Order> {
    return Promise(resolve: Order())
}

func getOrderError() -> Promise<Order> {
    return Promise(reject: NSError(domain: "", code: 0, userInfo: nil))
}

let promise = getUser()
    .then { _ in getEvent() }
    .then { _ in getUserError() }
    .catch { _ in getEvent() }
    .tap { print($0) }
    .then { _ in getOrder() }
    .tap { print($0) }
    .then { _ in getUserAsync() }
    .tap { print($0) }
    .then { _ in getOrderError() }
    .finally { print("done!") }

PlaygroundPage.current.needsIndefiniteExecution = true
