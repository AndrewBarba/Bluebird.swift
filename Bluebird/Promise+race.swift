//
//  Promise+race.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    public static func race<A>(_ promises: Promise<A>...) -> Promise<A> {
        return race(promises)
    }

    public static func race<A>(_ promises: [Promise<A>]) -> Promise<A> {
        return Promise<A> { resolve, reject in
            promises.forEach { $0.addHandler(resolve, reject) }
        }
    }
}
