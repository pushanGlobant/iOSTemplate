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

import UIKit
import RealmSwift

/// Class for performing database related operations as per application logic
class DatabaseService: NSObject {
    
    var databaseCore = DatabaseCore.sharedInstance
    
    /// Singletone initializer
    class var sharedInstance: DatabaseService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: DatabaseService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DatabaseService()
        }
        return Static.instance!
    }

    /**
    Save user object in database
    - parameter person: Person object
    */
    func saveUserData(person:Person) ->Void {
        databaseCore.saveObject(person)
    }
    
    /**
    Fetch user object from database
    - returns: PersonObject
    */
    func getUser() ->Person? {
        return databaseCore.retrieveObjects(Person).first
    }
}
