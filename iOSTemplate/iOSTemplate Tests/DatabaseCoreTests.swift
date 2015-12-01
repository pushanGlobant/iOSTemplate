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
@testable import iOSTemplate

class DatabaseCoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDatabaseWithPerson() {
        let email = "abc@xyz.com"
        let activated = 2
        let created = 1
        
        let person =  Person()
        person.email = email
        person.activated = activated
        person.created = created
        
        let databaseCore: DatabaseCore = DatabaseCore.sharedInstance
        databaseCore.saveObject(person)
        
        if let retrievedPerson = databaseCore.retrieveObjects(Person.self, predicate: NSPredicate(format: "email == %@", email)).first{
            XCTAssertEqual(retrievedPerson.email, person.email, "'email' property does not match")
            XCTAssertEqual(retrievedPerson.activated, person.activated, "'activated' property does not match")
            XCTAssertEqual(retrievedPerson.created, person.created, "'created' property does not match")
        }
        else{
            XCTFail("Saved Person object could not be retrieved")
        }
    }
    
}
