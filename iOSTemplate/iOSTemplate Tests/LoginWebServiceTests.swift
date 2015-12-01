/*
* Copyright 2015 Globant
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*    http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import XCTest
import Alamofire
@testable import iOSTemplate

class LoginWebServiceTests: XCTestCase, LoginWebServiceDelegate {
    var expectation:XCTestExpectation?
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExecuteNetworkCall() {
        expectation = expectationWithDescription("LoginExpectation")
        
        LoginWebService(delegate: self).executeWebService(HTTPMethod.POST, URLString: Constants.loginURL, parameters: ["email":TestConstants.username,"password":TestConstants.password], encoding: HTTPParameterEncoding.URL, headers: nil, completion: { (let response: AnyObject?, let error: NSError?) -> () in
            if let _ = response {
                XCTAssertNil(error, "Success and Error can not co-exist")
                XCTAssertNotNil(self.expectation, "No expextation is set")
                self.expectation!.fulfill()
            }
            else {
                XCTFail("Error in Login Service invocation: \(error?.localizedDescription)")
            }
        })
        
        waitForExpectationsWithTimeout(TestConstants.testTimeout, handler: { (let error) -> Void in
            if error != nil{
                XCTFail("Expectation failed; Error: \(error)")
            }
        })

    }
    
    func testLogin() {
        expectation = expectationWithDescription("LoginExpectation")
        LoginWebService(delegate: self).login(TestConstants.username, password: TestConstants.password)
        
        waitForExpectationsWithTimeout(TestConstants.testTimeout, handler: { (let error) -> Void in
            if error != nil{
                XCTFail("Expectation failed; Error: \(error)")
            }
        })
    }
    
    //Mark:- LoginWebServiceDelegate Methods 
    func loginWebService(service: LoginWebService, didFinishForPerson person: Person) -> Void{
        XCTAssertNotNil(expectation, "No expectation is set")
        expectation!.fulfill()
    }
    
    func loginWebService(service: LoginWebService, didFailWithError error: NSError) -> Void{
        XCTAssertNotNil(expectation, "No expectation is set")
        expectation!.fulfill()
    }
  }
