//
//  BluebirdTests.swift
//  BluebirdTests
//
//  Created by Andrew Barba on 2/2/18.
//  Copyright © 2018 Andrew Barba. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** https://github.com/google/promises
 Executes the given block multiple times according to the count variable and then returns
 the average number of nanoseconds per execution. Isn't listed in any public libdispatch header,
 although comes with a man page, so declaring manually here.
 */
FOUNDATION_EXTERN uint64_t dispatch_benchmark(size_t count, void (^block)(void));

NS_ASSUME_NONNULL_END

