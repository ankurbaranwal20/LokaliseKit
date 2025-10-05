//
//  LocalizationViewModel.swift
//

import Foundation

class LocalizationViewModel {
    
    private let service: LokalizationService
    
    init(service: LokalizationService = LokalizationService()) {
        self.service = service
    }
    
    /// Fetches localization keys from the provided URL and prepares the dynamic bundle for the given language.
    /// - Parameters:
    ///   - urlString: Remote JSON URL returning localization payload matching `LocalizationModel`.
    ///   - currentLanguageCode: Language code like "en", "ar".
    ///   - completion: Called on main thread after bundle is prepared.
    func getLocalizationData(urlString: String, currentLanguageCode: String ,completion: @escaping () -> Void) {
        service.getLocalisationDataFromBFFConsole(urlString: urlString, currentLanguageCode: currentLanguageCode) { [weak self] localizeKeysData in
            guard let self else { completion() ; return }
          self.handleLocalizationKeysData(localizeKeysData: localizeKeysData, completion: completion)
        } fail: { error in
            debugPrint(error.localizedDescription)
        }
    }
    
    private func handleLocalizationKeysData(localizeKeysData: [LocalisationKeys], completion: @escaping () -> Void) {
        LocalizableBundleManager.shared.writeLocalizationDataToBundle(localizeKeysData: localizeKeysData, {
            debugPrint("Lokalise updated successfully")
            completion()
        })
    }
}
