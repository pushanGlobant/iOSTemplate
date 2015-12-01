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

/// Protocol to be conformed by the class that uses the upload service
protocol UploadServiceDelegate: NSObjectProtocol {
    /**
    Method called to inform the delegate object that upload has succeeded
    - parameter service: The UploadService object
    */
    func uploadServiceDidFinishWithSuccess(service: UploadService) -> Void
    
    /**
    Method called to inform the delegate object that upload has made progress; this will be called iteratively everytime progress is made
    - parameter service: The UploadService object
    - parameter bytesSent: The bytes sent
    - parameter totalBytesSent: Total bytes sent
    - parameter totalBytesExpectedToSend: Total bytes expected to send.
    */
    func uploadServiceDidProgress(service: UploadService, bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) -> Void
    
    /**
    Method called to inform the delegate object that upload has failed with error
    - parameter service: The UploadService object
    - parameter error: The error object
    */
    func uploadService(service: UploadService, didFailWithError error: NSError) -> Void
}

/// Class providing facility for upload
class UploadService: HTTPServiceProtocol {
    weak var delegate:UploadServiceDelegate?
    
    /**
    Designated initializer for UploadService Class
    - parameter delegate: delegate object which is confirming to UploadServiceDelegate
    */
    init(delegate: UploadServiceDelegate) {
        self.delegate = delegate
    }
    
    /**
    Method providing delegate calls on completion
    - parameter success: Boolean specifying whether the service has succeeded
    - parameter error: Error object, if service failed
    */
    func completionHandler(success: Bool, error: NSError?) -> (){
        if success{
            self.delegate?.uploadServiceDidFinishWithSuccess(self)
        }
        else{
            if let err = error{
                self.delegate?.uploadService(self, didFailWithError: err)
            }
            else{
                self.delegate?.uploadService(self, didFailWithError: NSError(errorCode: ErrorCode.UnknownError))
            }
        }
    }
    
    /**
    Method for uploading data to a specified URL
    - parameter method: The HTTP method to be used
    - parameter URLString: The remote URL to which the data needs to be uploaded
    - parameter headers: HTTP headers, if any
    - parameter data: The data to be uploaded
    */
    func upload(method: HTTPMethod, URLString: String, headers: [String : String]?, data: NSData) {
        if Reachability(hostName: URLString).currentReachabilityStatus().rawValue == NotReachable.rawValue{
            delegate?.uploadService(self, didFailWithError: NSError(errorCode: ErrorCode.NetworkUnavailable))
            return
        }
        
        self.upload(method, URLString: URLString, headers: headers, data: data,
            progressHandler: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                self.delegate?.uploadServiceDidProgress(self, bytesSent: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
            }, completion: { (success: Bool, error: NSError?) -> () in
                self.completionHandler(success, error: error)
            }
        )
    }

    /**
    Method for uploading a file to a specified URL
    - parameter method: The HTTP method to be used
    - parameter URLString: The URL to which the file needs to be uploaded
    - parameter headers: HTTP headers, if any
    - parameter fileURL: The URL of the file to be uploaded
    */
    func upload(method: HTTPMethod, URLString: String, headers: [String : String]?, fileURL: NSURL) {
        if Reachability(hostName: URLString).currentReachabilityStatus().rawValue == NotReachable.rawValue{
            delegate?.uploadService(self, didFailWithError: NSError(errorCode: ErrorCode.NetworkUnavailable))
            return
        }
        
        self.upload(method, URLString: URLString, headers: headers, fileURL: fileURL,
            progressHandler: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                self.delegate?.uploadServiceDidProgress(self, bytesSent: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
            }, completion: { (success: Bool, error: NSError?) -> () in
                self.completionHandler(success, error: error)
            }
        )
    }
}