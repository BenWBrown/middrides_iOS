//
//  middridesTests.swift
//  middridesTests
//
//  Created by Ben Brown on 10/5/15.
//  Copyright © 2015 Ben Brown. All rights reserved.
//

import XCTest
import Parse
@testable import middrides

class middridesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    //Unit Tests:
    func testRegistration(){
        let rView = RegisterViewController();
        XCTAssert(rView.validRegisterDetails("", password: "") == false, "Registration validity check fails");
        XCTAssert(rView.validRegisterDetails("ab@middlebury.ed", password: "abcdefg") == false, "Registration   validity check fails");
        XCTAssert(rView.validRegisterDetails("ab@middlebury.edu", password: "") == false, "Registration validity check fails");
        XCTAssert(rView.validRegisterDetails("ab@middlebury.edu", password: "abcdef") == true, "Registration validity check fails");
    }
    
    func testLogin(){
        let lView = LoginViewController();
        XCTAssert(lView.validateLoginCredentials("", password: "") == .Invalid, "Registration validity check fails");
        XCTAssert(lView.validateLoginCredentials("ab@middlebury.ed", password: "abcdefg") == .Invalid, "Registration validity check fails");
        XCTAssert(lView.validateLoginCredentials("ab@middlebury.edu", password: "") == .Invalid, "Registration validity check fails");
        XCTAssert(lView.validateLoginCredentials("ab@middlebury.edu", password: "abcdefg") == .User, "Registration validity check fails");
        XCTAssert(lView.validateLoginCredentials("ab@middlebury.edu", password: "abc265/#g") == .User, "Registration validity check fails");
        XCTAssert(lView.validateLoginCredentials("cd@middlebury.edu", password: "abc265/#g") == .User, "Registration validity check fails");
        XCTAssert(lView.validateLoginCredentials("ab@middlebury.edu", password: "abcabc") == .User, "Registration validity check fails");
        //TODO: need to test the actual process of Parse checking the username/password
        //Need to try a login that is valid in terms of syntax but has wrong password
        
    }
    
    func testVanRequest() {
        let query = PFQuery(className: "UserRequest")
        var count = -1
        do {
            let objects = try query.findObjects()
            count = objects.count
        } catch _ {
            XCTAssert(false)
        }
        let vrView = VanRequestViewController()
        vrView.requestButtonPressed(UIButton())
        sleep(1) // wait for asynchronous part of requestButtonPressed() to finish
        var newCount = -1
        do {
            let objects = try query.findObjects()
            newCount = objects.count
        } catch _ {
            XCTAssert(false)
        }
        XCTAssertEqual(count, newCount-1)
    }
    
}
