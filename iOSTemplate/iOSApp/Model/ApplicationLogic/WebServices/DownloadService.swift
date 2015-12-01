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

/// Protocol to be conformed by the class that uses the download service
protocol DownloadServiceDelegate: NSObjectProtocol {
    /**
    Method called to inform the delegate object that download has succeeded
    - parameter service: The DownloadService object
    */
    func downloadServiceDidFinishWithSuccess(service: DownloadService) -> Void
    
    /**
    Method called to inform the delegate object that download has made progress; this will be called iteratively everytime progress is made
    - parameter service: The DownloadService object
    - parameter bytesWritten: The bytes written
    - parameter totalBytesWritten: Total bytes written
    - parameter totalBytesExpectedToWrite: Total bytes expected to write.
    */
    func downloadServiceDidProgress(service: DownloadService, bytesWritten:Int64, totalBytesWritten:Int64, totalBytesExpectedToWrite:Int64) -> Void
    
    /**
    Method called to inform the delegate object that download has failed with error
    - parameter service: The DownloadService object
    - parameter error: The error object
    */
    func downloadService(service: DownloadService, didFailWithError error: NSError) -> Void
}

/// Class providing facility for download
class DownloadService: HTTPServiceProtocol {
    weak var delegate:DownloadServiceDelegate?
    
    /**
    Designated initializer for DownloadService Class
    - parameter delegate: delegate object which is confirming to DownloadServiceDelegate
    */
    init(delegate: DownloadServiceDelegate) {
        self.delegate = delegate
    }
    
    /**
    Method for downloading data (file) from a specified URL
    - parameter URLString: The remote URL from which the file needs to be downloaded
    - parameter downloadLocationURL: The local URL where the file needs to be downloaded
    */
    func download(URLString: String, downloadLocationURL: NSURL){
        if Reachability(hostName: URLString).currentReachabilityStatus().rawValue == NotReachable.rawValue{
            delegate?.downloadService(self, didFailWithError: NSError(errorCode: ErrorCode.NetworkUnavailable))
            return
        }
        
        self.download(HTTPMethod.GET, URLString: URLString, parameters: nil, encoding: HTTPParameterEncoding.URL, headers: nil,
            destination: { (url: NSURL, response: NSHTTPURLResponse) -> NSURL in
                return downloadLocationURL
            },
            progressHandler:{ (bytesWritten:Int64, totalBytesWritten:Int64, totalBytesExpectedToWrite:Int64) -> Void in
                self.delegate?.downloadServiceDidProgress(self, bytesWritten: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            },
            completion: { (success: Bool, error: NSError?) -> () in
                if success{
                    self.delegate?.downloadServiceDidFinishWithSuccess(self)
                }
                else{
                    if let err = error{
                        self.delegate?.downloadService(self, didFailWithError: err)
                    }
                    else{
                        self.delegate?.downloadService(self, didFailWithError: NSError(errorCode: ErrorCode.UnknownError))
                    }
                }
            }
        )
    }
}
