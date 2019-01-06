//
//  ChatAppTests.swift
//  ChatAppTests
//
//  Created by Zinko Vyacheslav on 06.01.2019.
//  Copyright © 2019 Zinko Vyacheslav. All rights reserved.
//

import XCTest
// if "Missing required module 'Firebase'"   add   ${SRCROOT}/Pods/Firebase/CoreOnly/Sources   to 'Header Search Path'
@testable import ChatApp

class ChatAppTests: XCTestCase {
    

	func test_convertTime(){
		let result = Calculations.convertTime(seconds: 90)
		XCTAssertEqual(result, "1:30")
	}
	
	
	func testSome(){
		XCTFail()
	}

	
    
}
