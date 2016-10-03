//
//  BluebirdTests.swift
//  BluebirdTests
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

import XCTest
@testable import Bluebird

enum BluebirdTestError: Error {
    case int
    case string
}

func getInt(_ result: Int = 10) -> Promise<Int> {
    return Promise<Int> { resolve, _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            resolve(result)
        }
    }
}

func getIntError(_ result: Int = 10) -> Promise<Int> {
    return Promise<Int> { _, reject in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            reject(BluebirdTestError.int)
        }
    }
}

func getString(_ result: String = "Hello, Bluebird") -> Promise<String> {
    return Promise<String> { resolve, _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            resolve(result)
        }
    }
}

func getStringError(_ result: String = "Hello, Bluebird") -> Promise<String> {
    return Promise<String> { _, reject in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            reject(BluebirdTestError.string)
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
        XCTAssertEqual(p.error as! NSError, _error)
    }

    func testInitResolverRejectSyncRace() {
        let _result = 5
        let _error = NSError(domain: "", code: 0, userInfo: nil)
        let p = Promise<Int> { resolve, reject in
            reject(_error)
            resolve(_result)
        }
        XCTAssertEqual(p.error as! NSError, _error)
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
            XCTAssertEqual(BluebirdTestError.int, error as! BluebirdTestError)
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
            XCTAssertEqual(BluebirdTestError.string, error as! BluebirdTestError)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testCatchRecover() {
        let exp = expectation(description: "Promise.catch.recover")
        let int = 5
        let string = "Hello, Bluebird"
        getInt(int).then { _ in
            getStringError()
        }.then { _ in
            XCTFail()
        }.catch { _ in
            getString(string)
        }.then { result in
            XCTAssertEqual(result, string)
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
            XCTAssertEqual(error as! BluebirdTestError, BluebirdTestError.int)
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

    // MARK: - Join

    func testJoinArgs() {
        let exp = expectation(description: "Promise.join.args")
        let p1 = Promise<Int>(resolve: 1)
        let p2 = getInt(5)
        join(p1, p2).then { result in
            XCTAssertEqual(result.0, p1.result!)
            XCTAssertEqual(result.1, p2.result!)
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

    // MARK: - Map

    func testMapArray() {
        let exp = expectation(description: "Promise.map.array")
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
}
