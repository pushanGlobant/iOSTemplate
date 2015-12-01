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
import ObjectMapper

/// Protocol to be conformed by the class that uses the login service
protocol LoginWebServiceDelegate: NSObjectProtocol {
    /**
    Method called to inform the delegate object that login has succeeded
    - parameter service: The LoginWebService object
    - parameter person: The parsed Person object
    */
    func loginWebService(service: LoginWebService, didFinishForPerson person: Person) -> Void
    
    /**
    Method called to inform the delegate object that login has failed with error
    - parameter service: The LoginWebService object
    - parameter error: The error object
    */
    func loginWebService(service: LoginWebService, didFailWithError error: NSError) -> Void
}

/// Class providing facility for invoke web service for login
class LoginWebService: HTTPServiceProtocol {
    weak var delegate:LoginWebServiceDelegate?
    
    /**
    Designated initializer for LoginWebService Class
    - parameter delegate: delegate object which is confirming to LoginWebServiceDelegate
    */
    init(delegate: LoginWebServiceDelegate) {
        self.delegate = delegate
    }
    
    /**
    Method to call login web service using credintials
    - parameter username: username to be send as parameter
    - parameter password: password to be send as parameter
    */
    func login(username: String, password: String) {
        if Reachability(hostName: Constants.loginURL).currentReachabilityStatus().rawValue == NotReachable.rawValue{
            delegate?.loginWebService(self, didFailWithError: NSError(errorCode: ErrorCode.NetworkUnavailable))
            return
        }
        
        // Basic Implementation with no header
        executeWebService(HTTPMethod.POST, URLString: Constants.loginURL, parameters: ["email":username,"password":password], encoding: HTTPParameterEncoding.JSON, completion: { (let response: AnyObject?, let error: NSError?) -> () in
            self.handleResponse(response:response, error: error)
        })
        
        // Implementation with HTTP Headers
        /*executeWebService(HTTPMethod.POST, URLString: Constants.loginURL, parameters: ["email":username,"password":password], encoding: HTTPParameterEncoding.JSON, headers:["MyHeaderKey": "MyHeaderValue"], completion: { (let response: AnyObject?, let error: NSError?) -> () in
            self.handleResponse(response:response, error: error)
        })*/
        
        //Implementation with AuthenticationChallenge
        /*executeWebService(HTTPMethod.POST, URLString: Constants.loginURL, parameters: nil, encoding: HTTPParameterEncoding.JSON, headers: nil,
            challengeHandler: { (challenge: NSURLAuthenticationChallenge) -> (NSURLSessionAuthChallengeDisposition, NSURLCredential?) in
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic{
                    return (NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(user: username, password: password, persistence: NSURLCredentialPersistence.ForSession))
                }
                return (NSURLSessionAuthChallengeDisposition.PerformDefaultHandling, nil)
            },
            completion: { (let response: AnyObject?, let error: NSError?) -> () in
                self.handleResponse(response:response, error: error)
        })*/
    }
    
    /**
    Handle response object and accordingly sends callback
    - parameter response: Response Object to be handle
    - parameter error: Error object, if any
    */
    private func handleResponse(response response: AnyObject?, error: NSError?) ->Void {
        if let err = error{
            delegate?.loginWebService(self, didFailWithError: err)
            return
        }
        
        guard let responseDictionary = response as? [String:AnyObject], responseErrorCode = responseDictionary["errorCode"] as? Int
            else {
                delegate?.loginWebService(self, didFailWithError: NSError(errorCode: ErrorCode.UnknownError))
                return
        }
        
        var errorCode = ErrorCode.UnknownError
        if let errCode:ErrorCode = ErrorCode(rawValue: responseErrorCode) {
            errorCode = errCode
        }
        if errorCode == .NoError{
            guard let user = ObjectMapper.Mapper<Person>().map(responseDictionary["user"])
                else{
                    delegate?.loginWebService(self, didFailWithError: NSError(errorCode: ErrorCode.UnknownError))
                    return
            }
            DatabaseService.sharedInstance.saveUserData(user)
            delegate?.loginWebService(self, didFinishForPerson: user)
        }
        else{
            delegate?.loginWebService(self, didFailWithError: NSError(errorCode: errorCode))
        }
    }
}

