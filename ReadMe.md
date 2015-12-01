### iOSTemplate ###

===========================================================================

DESCRIPTION:

iOSTemplate is a project written in Swift 2.0 that includes the following features
- It integrates the following frameworks using Cocoapods:
    - Alamofire
    - Realm & RealmSwift
    - ObjectMapper
    - Reachability
- It implements interfaces for the above mentioned frameworks to facilitate easy integration with application logic.
- The project structure has been maintained in a way that can be replicated in all iOS projects.
- This project can be used as the starter for a new project.

===========================================================================

BUILD REQUIREMENTS:

iOS SDK 9.0 or later

===========================================================================

RUNTIME REQUIREMENTS:

iOS OS 8.0 or later

===========================================================================

PACKAGING LIST:

AppDelegate
- The shared application delegate class.

ViewController
- View controller used for the purpose of demonstrating different functionalities of the template.

Person
- Business Object class used to encapsulate an user's information.

HTTPServiceProtocol
- Protocol for HTTP URL connections. This protocol need to be extended by each web service protocol defined in project.
- Implements default implementations of the protocol as extension.
- This protocol is an application-independent interface to the underlying HTTP Networking framework. Alamofire is the underlying framework used in this template.

LoginWebService
- Service class providing facility for invoking web service for login.

DownloadService
- Service class providing facility for download.

UploadService
- Service class providing facility for upload.

DatabaseService
- Service class for performing database related operations as per application logic.

DatabaseCore
- Implementation of application-independent database access logic.
- This class is the interface to the underlying Database Management framework. RealmSwift is the underlying framework used in this template.

Constants
- Structure for storing global constants used in project.

Error
- Enumeration and NSError extension for error codes used in project. This can be extended/modified according to the purpose.

Logger
- Global Function for logging.

LocalizationUtility
- String Extension for simple Localization implementation.

TestConstants
- Constants used for Unit Test target.

LoginServiceTests
- XCTest cases for LoginWebService functionalities.

DatabaseCoreTests
- XCTest cases for DatabaseCore functionalities.

===========================================================================

CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- Integrated Alamofire, Realm, RealmSwift and ObjectMapper frameworks
- Implemented interfaces for underlying frameworks
- Added basic examples for interaction with interfaces to underlying frameworks

===========================================================================