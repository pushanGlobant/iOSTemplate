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

import Foundation
import ObjectMapper
import Realm
import RealmSwift

/// Model object used for storing details of a person
class Person: RealmSwift.Object, ObjectMapper.Mappable {
    
    dynamic var activated:Int = 0
    dynamic var created:Int = 0
    dynamic var email:String = ""
    
    // Mark:- Initializers
    required init() {
        super.init()
    }
    
    required init?(_ map: ObjectMapper.Map){
        super.init()
    }
    
    override init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    /**
    Maps the JSONObject response attributes directly into model object attributes.
    - parameter: map map object for model
    */
    internal func mapping(map: ObjectMapper.Map) {
        created  <- map["created"]
        activated  <- map["activated"]
        email  <- map["email"]
    }
    
    ///Sets property as primary key. Required when update true is used in add method of realm
    override static func primaryKey() -> String? {
        return "email"
    }
}
