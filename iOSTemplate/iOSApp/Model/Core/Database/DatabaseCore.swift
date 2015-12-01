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

/// Implementation of application-independent database access logic
class DatabaseCore: NSObject {
    /// Singletone Initializer for DatabaseCore
    class var sharedInstance: DatabaseCore {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : DatabaseCore? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DatabaseCore()
        }
        return Static.instance!
    }
    
    /// Realm object to perfom operation
    private lazy var realm: Realm? = {
        var realm:Realm? = nil
        do{
            realm  = try Realm()
        }
        catch let exception as NSError {
            print(exception.localizedDescription)
        }
        return realm
    }()
    
    /**
    Migrates Realm database to a newer version
    - parameter newVersion: version number need to set for Realm
    */
    func migrateDatabase(newVersion:Int){
        let config = Realm.Configuration(
            schemaVersion: UInt64(newVersion),
            migrationBlock: { (migration: RealmSwift.Migration, oldSchemaVersion: UInt64) in
                // To be populated with migration logic, example shown below
                /*if (oldSchemaVersion < 1) {
                // The enumerate(_:_:) method iterates over every Person object stored in the Realm file
                migration.enumerate(Person.className()) { oldObject, newObject in
                // combine name fields into a single field
                let firstName = oldObject!["firstName"] as! String
                let lastName = oldObject!["lastName"] as! String
                newObject!["fullName"] = "\(firstName) \(lastName)"
                }
                }*/
        })
        
        Realm.Configuration.defaultConfiguration = config
        do {
            realm = try Realm()
        }
        catch{
            print("Error in changing version for migration")
        }
    }
    
    /**
    Method to Save objects in Realm database
    - parameter object: Object to be saved
    */
    func saveObject(object:RealmSwift.Object) -> Void{
        guard let realm = realm
            else {
                return
        }
        
        do{
            try realm.write {
                realm.add(object, update: true)
            }
            print(realm.path)
        }
        catch let exception as NSError {
            print(exception)
        }
    }
    
    /**
    Method for fetching objects from Realm database
    - parameter type: Class Type of objects to be fetched
    - parameter predicate: Predicate to be applied on fetch results
    - returns: Array of fetchesd objects
    */
    func retrieveObjects<T: Object>(type: T.Type, predicate: NSPredicate? = nil) -> Array<T>{
        guard let realm = realm
            else {
                return Array<T>()
        }
        
        var objects: Results = realm.objects(type)
        if let l_predicate = predicate {
            objects = objects.filter(l_predicate)
        }
        return Array(objects)
    }
}
