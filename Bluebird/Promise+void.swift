//
//  Promise+Void.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    public var asVoid: Promise<Void> {
        return then { _ in }
    }
}

public func VoidPromise() -> Promise<Void> {
    return Promise<Void>(resolve: ())
}
