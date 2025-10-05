//
//  LokaliseKit.swift
//

import Foundation

public enum LokaliseKit {
    // Keep strong references to view models while requests are in-flight,
    // otherwise the Combine subscription may get cancelled early.
    private static var activeViewModels: [UUID: LocalizationViewModel] = [:]

    /// Enable to print debug logs from the SDK.
    public static var loggingEnabled: Bool = false

    static func log(_ message: @autoclosure () -> String) {
        if loggingEnabled { print("[LokaliseKit] \(message())") }
    }
    /// Convenience one-liner to prepare localization for a given language.
    /// - Parameters:
    ///   - urlString: Remote JSON endpoint for localization payload.
    ///   - languageCode: Language code like "en", "ar".
    ///   - completion: Called on main thread after dynamic bundle is ready.
    public static func initialize(urlString: String, languageCode: String = "en", completion: @escaping () -> Void) {
        
        let effectiveLanguage = LokaliseKitConfig.supportedLanguages.contains(languageCode)
                ? languageCode
                : LokaliseKitConfig.defaultLanguage
        
        let vm = LocalizationViewModel()
        let token = UUID()
        activeViewModels[token] = vm
        vm.getLocalizationData(urlString: urlString, currentLanguageCode: effectiveLanguage) {
            // Release strong reference after completion
            activeViewModels[token] = nil
            completion()
        }
    }
}
