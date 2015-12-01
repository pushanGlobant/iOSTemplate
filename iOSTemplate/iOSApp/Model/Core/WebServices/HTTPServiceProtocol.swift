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
import Alamofire

/// A closure executed once a request has successfully completed in order to determine where to move the temporary file written to during the download process. The closure takes two arguments: the temporary file URL and the URL response, and returns a single argument: the file URL where the temporary file should be moved.
public typealias HTTPDownloadFileDestination = (NSURL, NSHTTPURLResponse) -> NSURL

/// A closure that handles the Authentication Challenges. Its return values are: NSURLSessionAuthChallengeDisposition is One of several constants that describes how the challenge should be handled. NSURLCredential should be used for authentication if disposition is NSURLSessionAuthChallengeUseCredential, otherwise NULL.
public typealias HTTPAuthenticationChallengeHandler = ((NSURLAuthenticationChallenge) -> (NSURLSessionAuthChallengeDisposition, NSURLCredential?))

/// For uploads, the progress closure returns the bytes written, total bytes written, and total bytes expected to write.
public typealias HTTPUploadProgressHandler = ((bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) -> Void)

/// For downloads and data tasks, the progress closure returns the bytes read, total bytes read, and total bytes expected to read.
public typealias HTTPDownloadProgressHandler = ((bytesWritten:Int64, totalBytesWritten:Int64, totalBytesExpectedToWrite:Int64) -> Void)

/// HTTP Method to be used for network call
enum HTTPMethod: String{
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    
    func alamofireMethod() -> Alamofire.Method{
        return Alamofire.Method(rawValue: self.rawValue)!
    }
}

/// HTTP Parameter encoding to be used for network call
public enum HTTPParameterEncoding {
    case URL
    case URLEncodedInURL
    case JSON
    
    func alamofireParameterEncoding() -> Alamofire.ParameterEncoding{
        switch self{
        case .URL: return Alamofire.ParameterEncoding.URL
        case .URLEncodedInURL: return Alamofire.ParameterEncoding.URLEncodedInURL
        case .JSON: return Alamofire.ParameterEncoding.JSON
        }
    }
}

/// Protocol for HTTP URL connections. This protocol need to be extended by each web service protocol defined in project.
protocol HTTPServiceProtocol {
    func executeWebService(method: HTTPMethod, URLString: String, parameters: [String: AnyObject]?, encoding: HTTPParameterEncoding, headers: [String: String]?, challengeHandler: HTTPAuthenticationChallengeHandler?, completion: (response:AnyObject?, error: NSError?) -> ())
    
    func upload(method: HTTPMethod, URLString:String, headers:[String : String]?, data:NSData, progressHandler: HTTPUploadProgressHandler?, completion:(success:Bool, error: NSError?) -> ())
    
    func upload(method: HTTPMethod, URLString:String, headers:[String : String]?, fileURL:NSURL, progressHandler: HTTPUploadProgressHandler?, completion:(success:Bool, error: NSError?) -> ())
    
    func download(method: HTTPMethod, URLString: String, parameters: [String : AnyObject]?, encoding: HTTPParameterEncoding, headers: [String : String]?, destination: HTTPDownloadFileDestination, progressHandler: HTTPDownloadProgressHandler?, completion: (success: Bool, error: NSError?) -> ())
}


/// Protocol extension for HTTPServiceProtocol containing default implementaion for protocol methods
extension HTTPServiceProtocol {
    
    /**
    Method used for calling web service and receive the response
    - parameter method: HTTP Method
    - parameter URLString: Web API Endpoint
    - parameter parameters: HTTP request parameters
    - parameter encoding: Parameters encoding sucha as JSON, URL etc
    - parameter headers: HTTP header parameters
    - parameter challengeHandler: Closure for handling authentication challenges
    - parameter completion: Completion handler which gets called after execution of API call
    */
    func executeWebService(method: HTTPMethod, URLString: String, parameters: [String: AnyObject]? = nil, encoding: HTTPParameterEncoding = .URL, headers: [String: String]? = nil, challengeHandler: HTTPAuthenticationChallengeHandler? = nil, completion: (response:AnyObject?, error: NSError?) -> ()) {
        
        let manager = Alamofire.Manager.sharedInstance
        if let l_challengeHandler = challengeHandler{
            manager.delegate.sessionDidReceiveChallenge = { (session: NSURLSession, challenge: NSURLAuthenticationChallenge) -> (NSURLSessionAuthChallengeDisposition, NSURLCredential?) in
                return l_challengeHandler(challenge)
            }
        }
        manager.request(method.alamofireMethod(), URLString, parameters: parameters, encoding: encoding.alamofireParameterEncoding(), headers: headers)
            .responseJSON { (let response:Alamofire.Response<AnyObject, NSError>) -> Void in
                if let error = response.result.error {
                    completion(response: nil, error: error)
                }
                else {
                    guard let data = response.data
                        else {
                            completion(response: nil, error: NSError(errorCode: ErrorCode.NoDataReceived))
                            return
                    }
                    
                    do {
                        let unparsedObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as AnyObject
                        if let responseJson: AnyObject = unparsedObject  {
                            completion(response: responseJson, error: nil)
                        }
                    }
                    catch let exception as NSError {
                        completion(response: nil, error: exception)
                    }
                }
        }
    }
    
    /**
    Method used for uploading data to a given server URL
    - parameter method: HTTP Method
    - parameter URLString: Web API Endpoint
    - parameter headers: HTTP header parameters
    - parameter data: NSData which is intended to upload
    - parameter progressHandler: Progress closure for the upload
    - parameter completion: Completion handler which gets called after execution of API call
    */
    func upload(method:HTTPMethod, URLString:String, headers:[String : String]? = nil, data:NSData, progressHandler: HTTPUploadProgressHandler? = nil, completion:(success:Bool, error: NSError?) -> ()) {
        
        Alamofire.Manager.sharedInstance.upload(method.alamofireMethod(), URLString, headers: headers, data: data)
            .responseJSON { (let response:Alamofire.Response<AnyObject, NSError>) -> Void in
                self.handleWebResponse(response, completion: completion)
            }
            .progress { bytesSent, totalBytesSent, totalBytesExpectedToSend in
                dispatch_async(dispatch_get_main_queue()) {
                    if let progressClosure = progressHandler {
                        progressClosure(bytesSent: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
                    }
                }
        }
    }
    
    /**
    Method used for uploading file to a given server URL
    - parameter method: HTTP Method
    - parameter URLString: Web API Endpoint
    - parameter headers: HTTP header parameters
    - parameter fileURL: URL of file which is being upload
    - parameter progressHandler: progress closure for the upload
    - parameter completion: Completion handler which gets called after execution of API call
    */
    func upload(method:HTTPMethod, URLString:String, headers:[String : String]? = nil, fileURL:NSURL, progressHandler: HTTPUploadProgressHandler? = nil, completion:(success:Bool, error: NSError?) -> ()) {
        
        Alamofire.Manager.sharedInstance.upload(method.alamofireMethod(), URLString, headers: headers, file: fileURL)
            .responseJSON { (let response:Alamofire.Response<AnyObject, NSError>) -> Void in
                self.handleWebResponse(response, completion: completion)
            }
            .progress { bytesSent, totalBytesSent, totalBytesExpectedToSend in
                dispatch_async(dispatch_get_main_queue()) {
                    if let progressClosure = progressHandler {
                        progressClosure(bytesSent: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
                    }
                }
        }
    }
    
    /**
    Method to handle response object and accordingly send callback
    - parameter response: Response Object to be handle
    - parameter completion: Completion handler which gets called after execution of API call
    */
    private func handleWebResponse(response:Alamofire.Response<AnyObject, NSError>, completion:(success:Bool, error: NSError?)  -> ()) {
        if let error = response.result.error {
            completion(success: false, error: error)
        }
        else {
            completion(success: true, error: nil)
        }
    }
    
    /**
    Method used for downloading a file from a specified remote URL
    - parameter method: HTTP Method
    - parameter URLString: Remote URL from where download should occur
    - parameter parameters: HTTP request parameters
    - parameter encoding: Parameters encoding sucha as JSON, URL etc
    - parameter headers: HTTP header parameters
    - parameter destination: Closure providing the final location of the downloaded file
    - parameter progressHandler: Progress closure for the download
    - parameter completion: Completion handler which gets called after execution of API call
    */
    func download(method: HTTPMethod, URLString: String, parameters: [String : AnyObject]? = nil, encoding: HTTPParameterEncoding, headers: [String : String]? = nil, destination: HTTPDownloadFileDestination = Request.suggestedDownloadDestination(), progressHandler: HTTPDownloadProgressHandler? = nil, completion: (success: Bool, error: NSError?) -> ()){
        
        Alamofire.Manager.sharedInstance.download(method.alamofireMethod(), URLString, parameters: parameters, encoding: encoding.alamofireParameterEncoding(), headers: headers, destination: destination)
            .response(completionHandler: { (_, _, _, error: NSError?) -> Void in
                if let err = error{
                    completion(success: false, error: err)
                }
                else{
                    completion(success: true, error: nil)
                }
            })
            .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                print(totalBytesWritten)
                dispatch_async(dispatch_get_main_queue()) {
                    if let progressClosure = progressHandler {
                        progressClosure(bytesWritten: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
                    }
                }
        }
    }
}
