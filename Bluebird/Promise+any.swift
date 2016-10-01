//
//  Promise+race.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    public static func any<A>(_ promises: Promise<A>...) -> Promise<A> {
        return any(promises)
    }

    public static func any<A>(_ promises: [Promise<A>]) -> Promise<A> {
        guard promises.count > 0 else {
            return Promise<A>(reject: BluebirdError.rangeError)
        }

        return Promise<A> { resolve, reject in
            promises.forEach { $0.addHandlers(resolve, reject) }
        }
    }
}
