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

/// Error Domain used in the project
let iOSTemplateErrorDomain = "iOSTemplateErrorDomain"

/// Enumeration for Error Codes used with domain iOSTemplateErrorDomain
enum ErrorCode: Int {
    case NoError = 0
    case InvalidCredentials = 100
    case UserNotVerified = 101
    case UserBlocked = 102
    case NoDataReceived
    case NetworkUnavailable
    case UnknownError
    
    func localizedDescription() -> String{
        switch self{
        case .NoError:
            return "ErrorCode.NoError".localized
        case .InvalidCredentials:
            return "ErrorCode.InvalidCredentials".localized
        case .UserNotVerified:
            return "ErrorCode.UserNotVerified".localized
        case .UserBlocked:
            return "ErrorCode.UserBlocked".localized
        case .NoDataReceived:
            return "ErrorCode.NoDataReceived".localized
        case .NetworkUnavailable:
            return "ErrorCode.NetworkUnavailable".localized
        case .UnknownError:
            return "ErrorCode.UnknownError".localized
        }
    }
}

extension NSError{
    /**
    Initializer for NSError for a specified ErrorCode
    - parameter errorCode: The ErrorCode for which NSError needs to be generated
    */
    convenience init(errorCode: ErrorCode){
        self.init(domain: iOSTemplateErrorDomain, code: errorCode.rawValue, userInfo: [NSLocalizedDescriptionKey : errorCode.localizedDescription()])
    }
}