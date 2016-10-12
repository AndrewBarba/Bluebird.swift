//
//  Promise+errors.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Bluebird errors
///
/// - cancelled:  thrown when a Promise was explicity cancelled
/// - rangeError: thrown when a function that expects a non-empty array recieves an empty array
/// - timeout:    thrown if a Promise does not resolve in the givin number of seconds
public enum BluebirdError: Error {
    case cancelled
    case rangeError
    case timeout(TimeInterval)
}
