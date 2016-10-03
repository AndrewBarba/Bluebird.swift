//
//  BluebirdTests.swift
//  BluebirdTests
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

import XCTest
@testable import Bluebird

class BluebirdTests: XCTestCase {

    let defaultTimeout: TimeInterval = 1.0

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

    // MARK: - Catch

    // MARK: - Tap
}
