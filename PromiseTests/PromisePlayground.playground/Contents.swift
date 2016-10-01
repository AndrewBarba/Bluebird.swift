//: Playground - noun: a place where people can play

import Promise

struct User {}

struct Event {}

struct Order {}

func getUser() -> Promise<User> {
    return Promise(result: User())
}

func getUserError() -> Promise<User> {
    return Promise(error: NSError(domain: "", code: 0, userInfo: nil))
}

func getEvent() -> Promise<Event> {
    return Promise(result: Event())
}

func getEventError() -> Promise<Event> {
    return Promise(error: NSError(domain: "", code: 0, userInfo: nil))
}

func getOrder() -> Promise<Order> {
    return Promise(result: Order())
}

func getOrderError() -> Promise<Order> {
    return Promise(error: NSError(domain: "", code: 0, userInfo: nil))
}

let promise = getUser()
    .then { _ in getEvent() }
    .then { _ in getUserError() }
    .catch { _ in getEvent() }
    .tap { print($0) }
    .then { _ in getOrder() }
    .tap { print($0) }
