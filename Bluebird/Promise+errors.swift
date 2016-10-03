//
//  Promise+errors.swift
//  Bluebird
//
//  Created by Andrew Barba on 10/1/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Bluebird errors
///
/// - rangeError: thrown when a function that expects a non-empty array recieves an empty array
public enum BluebirdError: Error {
    case rangeError
}
