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

class ViewController: UIViewController, LoginWebServiceDelegate, DownloadServiceDelegate, UploadServiceDelegate {

    @IBOutlet weak var askLoginLabel: UILabel!
    @IBOutlet weak var askInfoLabel: UILabel!
    @IBOutlet weak var askDownloadLabel: UILabel!
    @IBOutlet weak var askUploadLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    
    let internetReachability = Reachability.reachabilityForInternetConnection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        askLoginLabel.text = "viewcontroller.ask_login_label.text".localized
        askInfoLabel.text = "viewcontroller.ask_info_label.text".localized
        askDownloadLabel.text = "viewcontroller.ask_download_label.text".localized
        askUploadLabel.text = "viewcontroller.ask_upload_label.text".localized
        
        loginButton.setTitle("viewcontroller.login_button.title".localized, forState: .Normal)
        infoButton.setTitle("viewcontroller.info_button.title".localized, forState: .Normal)
        downloadButton.setTitle("viewcontroller.download_button.title".localized, forState: .Normal)
        uploadButton.setTitle("viewcontroller.upload_button.title".localized, forState: .Normal)
        
        
        // Invoke Reachability
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        
        internetReachability.startNotifier()
        performOperationForNetworkStatus(internetReachability.currentReachabilityStatus())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button actions
    @IBAction func loginPressed(sender: AnyObject) {
        let loginWebService = LoginWebService(delegate: self)
        loginWebService.login("nirmal.choudhari@globant.com", password: "Cya$$")
    }
    
    @IBAction func infoPressed(sender: AnyObject) {
        if let user = DatabaseService.sharedInstance.getUser(){
            print(user)
        }
    }
    
    @IBAction func downloadPressed(sender: AnyObject){
        var downloadDirectoryPath = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first! as NSString).stringByAppendingPathComponent("Downloads")

        let fileManager = NSFileManager.defaultManager()
        do{
            try fileManager.createDirectoryAtPath(downloadDirectoryPath, withIntermediateDirectories: true, attributes: nil)
        }
        catch{
            downloadDirectoryPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        }
        
        let downloadLocationPath = (downloadDirectoryPath as NSString).stringByAppendingPathComponent("earth.jpg")
        let downloadLocationURL = NSURL(fileURLWithPath: downloadLocationPath)
        
        let downloadService: DownloadService = DownloadService(delegate: self)
        downloadService.download("https://upload.wikimedia.org/wikipedia/commons/9/97/The_Earth_seen_from_Apollo_17.jpg", downloadLocationURL: downloadLocationURL)
        
//        let downloadService: DownloadService = DownloadService(delegate: self)
//        if let downloadLocationURL = NSURL(string: "<DOWNLOAD_LOCATION_URL>"){
//            downloadService.download("<DOWNLOAD_URL_STRING>", downloadLocationURL: downloadLocationURL)
//        }
    }
    
    @IBAction func uploadPressed(sender: AnyObject){
        let uploadService: UploadService = UploadService(delegate: self)
        if let fileURL = NSURL(string: "<FILE_URL>"){
            uploadService.upload(HTTPMethod.POST, URLString: "<UPLOAD_URL_STRING>", headers: nil, fileURL: fileURL)
        }
    }
    
    // MARK: LoginWebServiceDelegate Methods
    func loginWebService(service: LoginWebService, didFinishForPerson person: Person) -> Void{
        print("User loggedIn Successfully for email \(person.email)")
    }
    
    func loginWebService(service: LoginWebService, didFailWithError error: NSError) -> Void{
        print("error: \(error.localizedDescription)")
    }
    
    // MARK: DownloadServiceDelegate Methods
    func downloadServiceDidFinishWithSuccess(service: DownloadService) -> Void{
        print("download success")
    }
    
    func downloadService(service: DownloadService, didFailWithError error: NSError) -> Void{
        print("download error: \(error.localizedDescription)")
    }
    
    func downloadServiceDidProgress(service: DownloadService, bytesWritten:Int64, totalBytesWritten:Int64, totalBytesExpectedToWrite:Int64) -> Void{
        print("download progress: \((Float64(totalBytesWritten)/Float64(totalBytesExpectedToWrite))*100.0)%")
    }

    // MARK: DownloadServiceDelegate Methods
    func uploadServiceDidFinishWithSuccess(service: UploadService) -> Void{
        print("upload success")
    }
    
    func uploadServiceDidProgress(service: UploadService, bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) -> Void{
        print("upload progress: \((Float64(totalBytesSent)/Float64(totalBytesExpectedToSend))*100.0)%")
    }
    
    func uploadService(service: UploadService, didFailWithError error: NSError) -> Void{
        print("upload error: \(error.localizedDescription)")
    }
    
    /**
    Method to receive notification on change of network state
    - parameter notification: The notification object for kReachabilityChangedNotification
    */
    func reachabilityChanged(notification: NSNotification) -> Void{
        guard let reachability = notification.object as? Reachability
            else{
                return
        }
        performOperationForNetworkStatus(reachability.currentReachabilityStatus())
    }
    
    /**
    Method to perform action on receiving a network status from Reachbility; can be used for updating the UI or performing other actions
    - parameter networkStatus: The Network status for which operation would be performed
    */
    func performOperationForNetworkStatus(networkStatus: NetworkStatus) -> Void{
        switch networkStatus.rawValue{
        case NotReachable.rawValue:
            print("Internet is not reachable")
            
        case ReachableViaWiFi.rawValue:
            print("Internet is reachable via WiFi")
            
        case ReachableViaWWAN.rawValue:
            print("Internet is reachable via WWAN")
            
        default:
            break
        }
    }

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
