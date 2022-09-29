//
//  LanguageManager.swift
//  GetAllHealthData
//
//  Created by ROLF J. on 2022/09/05.
//

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
