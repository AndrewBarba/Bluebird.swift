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

    func testInitResolverResolve() {
        let exp = expectation(description: "Promise.init.resolver.resolve")
        let _result = 5
        Promise<Int> { resolve, _ in
            resolve(_result)
        }.then { result in
            XCTAssertEqual(result, _result)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testInitResolverReject() {
        let exp = expectation(description: "Promise.init.resolver.reject")
        let _error = NSError(domain: "", code: 0, userInfo: nil)
        Promise<Int> { _, reject in
            reject(NSError(domain: "", code: 0, userInfo: nil))
        }.catch { error in
            XCTAssertEqual(error as NSError, _error)
            exp.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: - Then

    // MARK: - Catch

    // MARK: - Tap
}
