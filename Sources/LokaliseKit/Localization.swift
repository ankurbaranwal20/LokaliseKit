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
    public func localized(defaultKey: DefaultLocalization = .unknown) -> String {

        let initialTranslation = NSLocalizedString(self, tableName: "", bundle: LocalizableBundleManager.shared.currentBundle, value: "", comment: "")
        let finalTranslation: String
        
        if case DefaultLocalization.unknown = defaultKey {
            if self == initialTranslation {
                // translation not found on lokalise -> return from local string files
                finalTranslation = fetchTranslationFromLocalBundle()
            } else {
                // translation found on lokalise
                finalTranslation = initialTranslation
            }
        } else {
            if self == initialTranslation || initialTranslation.isEmpty {
                // translation not found on lokalise or it's empty -> return default translation
                finalTranslation =  NSLocalizedString(defaultKey.key, tableName: "", bundle: LocalizableBundleManager.shared.currentBundle, value: defaultKey.key, comment: "")
            } else {
                // translation found on lokalise
                finalTranslation = initialTranslation
            }
        }
        return finalTranslation.replacingOccurrences(of: "[%s]", with: "%@")
            .replacingOccurrences(of: "%s", with: "%@")
    }
    
    public func localizedFormatted(_ arguments: any CVarArg...) -> String? {
        let value = self.localized()
        if self == value || value.isEmpty {
            return nil
        }
        if value.contains("%@") {
            return String(format: self.localized(), arguments: arguments)
        } else {
            return value
        }
    }
}
