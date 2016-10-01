//
//  Promise+Void.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    public static func Void() -> Promise<Void> {
        return Promise<Void>(resolve: ())
    }

    public var asVoid: Promise<Void> {
        return then { _ in }
    }
}
