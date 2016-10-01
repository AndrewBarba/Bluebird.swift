//
//  Promise+All.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

extension Promise {

    public static func all<A>(_ promises: Promise<A>...) -> Promise<[A]> {
        return all(promises)
    }

    public static func all<A>(_ promises: [Promise<A>]) -> Promise<[A]> {
        guard promises.count > 0 else { return Promise<[A]>(resolve: []) }

        return Promise<[A]> { resolve, reject in

            var remaining = promises.count

            let queue = DispatchQueue(label: "com.abarba.Bluebird.join")

            let check: (A) -> () = { _ in
                remaining -= 1
                guard remaining == 0 else { return }
                resolve(promises.map { $0.result! })
            }

            promises.forEach { $0.addHandlers(on: queue, check, reject) }
        }
    }
}
