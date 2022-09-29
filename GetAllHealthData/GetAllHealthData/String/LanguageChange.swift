//
//  LanguageManager.swift
//  GetAllHealthData
//
//  Created by ROLF J. on 2022/09/05.
//

import Foundation

struct LanguageChange {
    
    // Sign in view
    struct SignInViewWord {
        static let signInLabel = "signInLabel".localized
        static let signInPlaceHolder = "signInPlaceHolder".localized
        static let signInButton = "signInButton".localized
    }
    
    // Main view
    struct MainViewWord {
        static let startTimeLabel = "startTimeLabel".localized
        static let endTimeLabel = "endTimeLabel".localized
        static let queryButton = "queryButton".localized
    }
    
    // Alert
    struct AlertWord {
        static let alertConfirm = "alertConfirm".localized
        static let alertCancel = "alertCancel".localized
        static let onlyNumber = "onlyNumber".localized
        static let IDLength3 = "IDLength3".localized
        static let typeAgain = "typeAgain".localized
        static let signInComplete = "signInComplete".localized
        static let restartRequest = "restartRequest".localized
    }
    
}
