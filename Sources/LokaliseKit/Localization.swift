//
//  Localization.swift
//

import Foundation

public extension String {
    
    public enum DefaultLocalization {
        case unknown
        
        public var key: String {
            switch self {
            case .unknown:
                return ""
            }
        }
    }
    
    public func fetchTranslationFromLocalBundle() -> String {
        guard !(LocalizableBundleManager.shared.isLocalLocalizableBundleIsLoaded())  else {
            return "" }
        let translation = NSLocalizedString(self, tableName: "", bundle: LocalizableBundleManager.shared.getLocalBundle(), value: "", comment: "")
        return translation == self ? "" : translation
    }
    public func localized() -> String {

        let initialTranslation = NSLocalizedString(self, tableName: "", bundle: LocalizableBundleManager.shared.currentBundle, value: "", comment: "")
        let finalTranslation: String
        
        if self == initialTranslation {
            // translation not found on lokalise -> return from local string files
            finalTranslation = fetchTranslationFromLocalBundle()
        } else {
            // translation found on lokalise
            finalTranslation = initialTranslation
        }
        return finalTranslation.replacingOccurrences(of: "[%s]", with: "%@")
            .replacingOccurrences(of: "%s", with: "%@")
    }
}
