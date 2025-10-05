//
//  LokalizationService.swift
//

import Foundation
import Combine

final class LokalizationService {
    
    private let client: HTTPClientProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(client: HTTPClientProtocol = HTTPClient()) {
        self.client = client
    }
    
    func getLocalisationDataFromBFFConsole(
        urlString: String,
        currentLanguageCode: String,
        success: @escaping (_ localizeKeysData: [LocalisationKeys]) -> Void,
        fail: @escaping (_ error: NSError) -> Void
    ) {
        LocalizableBundleManager.shared.currentLanguage = currentLanguageCode
        let urlWithLanguage = "\(urlString)/\(currentLanguageCode).json"
        LokaliseKit.log("Starting localization fetch. lang=\(currentLanguageCode), url=\(urlWithLanguage)")
        guard let url = URL(string: urlWithLanguage) else {
            LokaliseKit.log("Invalid URL: \(urlWithLanguage)")
            fail(NSError(domain: "InvalidURL", code: -1))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        client.request(request, decodeTo: LocalizationModel.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LokaliseKit.log("Localization fetch finished")
                    break
                case .failure(let error):
                    LokaliseKit.log("Localization fetch failed: \(error.localizedDescription)")
                    fail(error as NSError)
                }
            }, receiveValue: { model in
                LokaliseKit.log("Localization fetch success: keys=\(model.localiseKeys.count)")
                success(model.localiseKeys)
            })
            .store(in: &cancellables)
        
    }
}
