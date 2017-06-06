//
//  BluebirdTests.swift
//  BluebirdTests
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

import XCTest
@testable import Bluebird

enum TestError: Error {
    case int
    case string
}

func getInt(delay: TimeInterval = 0.1, _ result: Int = 10) -> Promise<Int> {
    return Promise<Int> { resolve, _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            resolve(result)
        }
    }
}

func getIntError(delay: TimeInterval = 0.1, _ result: Int = 10) -> Promise<Int> {
    return Promise<Int> { _, reject in
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            reject(TestError.int)
        }
    }
}

func getString(delay: TimeInterval = 0.1, _ result: String = "Hello, Bluebird") -> Promise<String> {
    return Promise<String> { resolve, _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            resolve(result)
        }
    }
}

func getStringError(delay: TimeInterval = 0.1, _ result: String = "Hello, Bluebird") -> Promise<String> {
    return Promise<String> { _, reject in
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            reject(TestError.string)
        }
    }
}

class BluebirdTests: XCTestCase {

    let defaultTimeout: TimeInterval = 5.0

    // MARK: - Init

    func testInitResolved() {
        let promise: Promise<Int> = Promise(resolve: 10)
        XCTAssertNil(promise.error)
        XCTAssertNotNil(promise.result)
    }
    
    func testInitRejected() {
        let promise: Promise<Int> = Promise(reject: NSError(domain: "", code: 0, userInfo: nil))
        XCTAssertNil(promise.result)
        XCTAssertNotNil(promise.error)
    }

    func testInitResolverResolveSync() {
        let _result = 5
        let p = Promise<Int> { resolve, _ in
            resolve(_result)
        }
        XCTAssertEqual(p.result!, _result)
    }

    func testInitResolverResolveSyncRace() {
        let _result = 5
        let _error = NSError(domain: "", code: 0, userInfo: nil)
        let p = Promise<Int> { resolve, reject in
            resolve(_result)
            reject(_error)
        }
        XCTAssertEqual(p.result!, _result)
        XCTAssertNil(p.error)
    }

    func testInitResolverResolveAsync() {
        let exp = expectation(description: "Promise.init.resolver.resolve")
        let _result: Int = 5
        Promise<Int> { resolve, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                resolve(5)
            }
        }.then { result in
            XCTAssertEqual(result, _result)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testInitResolverRejectSync() {
        let _error = NSError(domain: "", code: 0, userInfo: nil)
        let p = Promise<Int> { _, reject in
            reject(_error)
        }
        XCTAssertEqual(p.error! as NSError, _error)
    }

    func testInitResolverRejectSyncRace() {
        let _result = 5
        let _error = NSError(domain: "", code: 0, userInfo: nil)
        let p = Promise<Int> { resolve, reject in
            reject(_error)
            resolve(_result)
        }
        XCTAssertEqual(p.error! as NSError, _error)
        XCTAssertNil(p.result)
    }

    func testInitResolverRejectAsync() {
        let exp = expectation(description: "Promise.init.resolver.reject")
        let _error = NSError(domain: "", code: 0, userInfo: nil)
        Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                reject(NSError(domain: "", code: 0, userInfo: nil))
            }
        }.catch { error in
            XCTAssertEqual(error as NSError, _error)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testInitResolverPromise() {
        let exp = expectation(description: "Promise.init.resolver.promise")
        let promise = VoidPromise()
        let p = Promise<Void> {
            return promise
        }.then {
            exp.fulfill()
        }
        XCTAssertNil(p.result)
        XCTAssertNil(p.error)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Then

    func testThenSingle() {
        let exp = expectation(description: "Promise.then.single")
        let int = 5
        getInt(int).then { result in
            XCTAssertEqual(result, int)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testThenPromise() {
        let exp = expectation(description: "Promise.then.promise")
        let int = 5
        getInt(int).then {
            getString("\($0)")
        }.then {
            XCTAssertEqual($0, "\(int)")
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testThenValue() {
        let exp = expectation(description: "Promise.then.value")
        let int = 5
        getInt(int).then {
            "\($0)"
        }.then {
            XCTAssertEqual($0, "\(int)")
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Catch

    func testCatchSingle() {
        let exp = expectation(description: "Promise.catch.single")
        let int = 5
        getIntError(int).then { _ in
            XCTFail()
        }.catch { error in
            XCTAssertEqual(TestError.int, error as! TestError)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testCatchChain() {
        let exp = expectation(description: "Promise.catch.chain")
        let int = 5
        getInt(int).then { _ in
            getStringError()
        }.then { _ in
            XCTFail()
        }.catch { error in
            XCTAssertEqual(TestError.string, error as! TestError)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testCatchRecoverPromise() {
        let exp = expectation(description: "Promise.catch.recover.promise")
        let int = 5
        let string = "Hello, Bluebird"
        getInt(int).then { _ in
            getStringError()
        }.tap { _ in
            XCTFail()
        }.catchThen { _ in
            getString(string)
        }.then { result in
            XCTAssertEqual(result, string)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testCatchRecoverVoid() {
        let exp = expectation(description: "Promise.catch.recover.promise")
        getInt().then { _ in
            getStringError()
        }.then { _ in
            XCTFail()
        }.catch { error in
            XCTAssertEqual(error as! TestError, TestError.string)
        }.then { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Tap

    func testTapSingle() {
        let exp = expectation(description: "Promise.tap.single")
        let int = 5
        getInt(int).tap { result in
            XCTAssertEqual(result, int)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testTapChain() {
        let exp = expectation(description: "Promise.tap.chain")
        let int = 5
        let string = "Hello, World"
        getInt(int).tap { result in
            XCTAssertEqual(result, int)
        }.then { result -> Promise<String> in
            XCTAssertEqual(result, int)
            return getString(string)
        }.tap { result in
            XCTAssertEqual(result, string)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testTapPromise() {
        let exp = expectation(description: "Promise.tap.promise")
        let int = 5
        var string: String? = nil
        getInt(int).then { result -> Promise<String> in
            XCTAssertEqual(result, int)
            return getString().tap { string = $0 }
        }.tap { result in
            XCTAssertEqual(result, string!)
            exp.fulfill()

        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Finally

    func testFinallySingle() {
        let exp = expectation(description: "Promise.finally.single")
        getInt().finally {
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testFinallyError() {
        let exp = expectation(description: "Promise.finally.error")
        getIntError().finally {
            exp.fulfill()
        }.catch { error in
            XCTAssertEqual(error as! TestError, TestError.int)
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Any/Race

    func testAnyArgs() {
        let exp = expectation(description: "Promise.any.args")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getInt(5)
        any(p1, p2).then { result in
            XCTAssertEqual(result, p1.result!)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testAnyArray() {
        let exp = expectation(description: "Promise.any.array")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getInt(5)
        any([p1, p2]).then { result in
            XCTAssertEqual(result, p1.result!)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testRaceArgs() {
        let exp = expectation(description: "Promise.race.args")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getInt(5)
        race(p1, p2).then { result in
            XCTAssertEqual(result, p1.result!)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testRaceArray() {
        let exp = expectation(description: "Promise.race.array")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getInt(5)
        race([p1, p2]).then { result in
            XCTAssertEqual(result, p1.result!)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Join

    func testJoinTwo() {
        let exp = expectation(description: "Promise.join.two")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getString("hello")
        join(p1, p2).then { int, string in
            XCTAssertEqual(int, p1.result!)
            XCTAssertEqual(string, p2.result!)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testJoinThree() {
        let exp = expectation(description: "Promise.join.three")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getString("hello")
        let p3 = getString("hello2")
        join(p1, p2, p3).then { int, string1, string2 in
            XCTAssertEqual(int, p1.result!)
            XCTAssertEqual(string1, p2.result!)
            XCTAssertEqual(string2, p3.result!)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testJoinFour() {
        let exp = expectation(description: "Promise.join.four")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getString("hello")
        let p3 = getString("hello2")
        let p4 = getString("hello3")
        join(p1, p2, p3, p4).then { int, string1, string2, string3 in
            XCTAssertEqual(int, p1.result!)
            XCTAssertEqual(string1, p2.result!)
            XCTAssertEqual(string2, p3.result!)
            XCTAssertEqual(string3, p4.result!)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - All

    func testAllArgs() {
        let exp = expectation(description: "Promise.all.args")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getInt(5)
        all(p1, p2).then { results in
            XCTAssertEqual(results[0], p1.result!)
            XCTAssertEqual(results[1], p2.result!)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testAllArray() {
        let exp = expectation(description: "Promise.all.array")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getInt(5)
        all([p1, p2]).then { results in
            XCTAssertEqual(results[0], p1.result!)
            XCTAssertEqual(results[1], p2.result!)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testAllArrayError() {
        let exp = expectation(description: "Promise.all.array.error")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getIntError()
        all([p1, p2]).then { results in
            XCTFail()
        }.catch { error in
            XCTAssertEqual(error as! TestError, TestError.int)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Map

    func testMapConcurrent() {
        let exp = expectation(description: "Promise.map.concurrent")
        let arr = [1, 10, 5, 6, 8, 94, 4]
        map(arr) { getInt($0) }
            .then { results in
                XCTAssertEqual(results.count, arr.count)
                for (index, result) in results.enumerated() {
                    XCTAssertEqual(result, arr[index])
                }
                exp.fulfill()
            }
            .catch { _ in
                XCTFail()
            }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testMapSeries() {
        let exp = expectation(description: "Promise.map.series")
        let arr = [1, 10, 5, 6, 8, 94, 4]
        mapSeries(arr) { getInt($0) }
            .then { results in
                XCTAssertEqual(results.count, arr.count)
                for (index, result) in results.enumerated() {
                    XCTAssertEqual(result, arr[index])
                }
                exp.fulfill()
            }
            .catch { _ in
                XCTFail()
            }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testMapChain() {
        let exp = expectation(description: "Promise.map.chain.concurrent")
        let arr = [1, 10, 5, 6, 8, 94, 4]
        map(arr) { getInt($0) }
            .map { getInt($0 + 1) }
            .then { results in
                XCTAssertEqual(results.count, arr.count)
                for (index, result) in results.enumerated() {
                    XCTAssertEqual(result, arr[index] + 1)
                }
                exp.fulfill()
            }
            .catch { _ in
                XCTFail()
            }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testMapSeriesChain() {
        let exp = expectation(description: "Promise.map.chain.series")
        let arr = [1, 10, 5, 6, 8, 94, 4]
        mapSeries(arr) { getInt($0) }
            .mapSeries { getInt($0 + 1) }
            .then { results in
                XCTAssertEqual(results.count, arr.count)
                for (index, result) in results.enumerated() {
                    XCTAssertEqual(result, arr[index] + 1)
                }
                exp.fulfill()
            }
            .catch { _ in
                XCTFail()
            }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Reduce

    func testReduce() {
        let exp = expectation(description: "Promise.reduce")
        reduce([1, 2, 3, 4, 5], 0) { partial, item in
            return getInt(2).then { partial + (item * $0) }
        }.then { result in
            XCTAssertEqual(result, 30)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testReduceChain() {
        let exp = expectation(description: "Promise.reduce.chain")
        map([1, 2, 3, 4, 5]) {
            getInt($0)
        }.reduce(0) { partial, item in
            return getInt(2).then { partial + (item * $0) }
        }.then { result in
            XCTAssertEqual(result, 30)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testReduceError() {
        let exp = expectation(description: "Promise.reduce")
        reduce([1, 2, 3, 4, 5], 0) { partial, item in
            guard partial < 10 else { return getIntError() }
            return getInt(2).then { partial + (item * $0) }
        }.then { _ in
            XCTFail()
        }.catch { error in
            XCTAssertEqual(error as! TestError, TestError.int)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - reflect

    func testReflect() {
        let exp = expectation(description: "Promise.reflect")
        let p1 = Promise<Int>(resolve: 1).reflect()
        let p2 = getIntError().reflect()
        all([p1, p2]).then { results in
            XCTAssertNotNil(results[0].result)
            XCTAssertNotNil(results[1].error)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - defer

    func testDefer() {
        let exp = expectation(description: "Promise.defer")
        let resolver = Promise<Int>.defer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            resolver.resolve(5)
        }
        resolver.promise.then { result in
            XCTAssertEqual(result, 5)
            exp.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testDeferError() {
        let exp = expectation(description: "Promise.defer.error")
        let resolver = Promise<Int>.defer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            resolver.reject(TestError.int)
        }
        resolver.promise.then { result in
            XCTFail()
        }.catch { error in
            XCTAssertEqual(error as! TestError, TestError.int)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Timeout

    func testTimeout() {
        let exp = expectation(description: "Promise.timeout")
        getInt(delay: 0.25, 7)
            .timeout(0.5)
            .then { result in
                XCTAssertEqual(7, result)
                exp.fulfill()
            }
            .catch { error in
                XCTFail()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testTimeoutError() {
        let exp = expectation(description: "Promise.timeout.error")
        getInt(delay: 0.5)
            .timeout(0.25)
            .then { _ in
                XCTFail()
            }
            .catch { error in
                switch error as! BluebirdError {
                case .timeout(let seconds):
                    XCTAssertEqual(0.25, seconds)
                default:
                    XCTFail()
                }
                exp.fulfill()
            }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Delay

    func testDelay() {
        let exp = expectation(description: "Promise.delay")
        let start = Date().timeIntervalSince1970
        getInt(5)
            .delay(1.0)
            .then { result in
                let diff = Date().timeIntervalSince1970 - start
                XCTAssertGreaterThan(diff, 1.0)
                XCTAssertLessThan(diff, 2.0)
                exp.fulfill()
            }
            .catch { _ in
                XCTFail()
            }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
}
