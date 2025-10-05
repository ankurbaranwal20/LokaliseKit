//
//  LokalizationModel.swift
//

import Foundation

struct LocalizationModel : Codable {
    let localiseKeys : [LocalisationKeys]
    
    enum CodingKeys: String, CodingKey {
        case localiseKeys = "keys"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        localiseKeys = try values.decodeIfPresent([LocalisationKeys].self, forKey: .localiseKeys) ?? []
    }
}

struct LocalisationKeys : Codable {
    let key : String
    let translations : [Translations]?
    let cTaggedData: Bool
    let keyName : KeysName?
    let isPlural: Bool
    
    var localiseKeyName: String {
        if let keyName = keyName?.ios {
            return keyName
        } else {
            return key
        }
    }

    enum CodingKeys: String, CodingKey {
        case key = "key"
        case translations = "translations"
        case cTaggedData = "CTaggedData"
        case keyName = "key_name"
        case isPlural = "is_plural"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decodeIfPresent(String.self, forKey: .key) ?? ""
        translations = try values.decodeIfPresent([Translations].self, forKey: .translations) ?? []
        cTaggedData = try values.decodeIfPresent(Bool.self, forKey: .cTaggedData) ?? false
        keyName = try values.decodeIfPresent(KeysName.self, forKey: .keyName)
        isPlural = try values.decodeIfPresent(Bool.self, forKey: .isPlural) ?? false
    }
    
}

struct KeysName : Codable {
    let ios : String?
    let android : String?
    let web : String?
    let other : String?
    
    enum CodingKeys: String, CodingKey {
        
        case ios = "ios"
        case android = "android"
        case web = "web"
        case other = "other"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ios = try values.decodeIfPresent(String.self, forKey: .ios)
        android = try values.decodeIfPresent(String.self, forKey: .android)
        web = try values.decodeIfPresent(String.self, forKey: .web)
        other = try values.decodeIfPresent(String.self, forKey: .other)
    }
    
}

struct Translations : Codable {
    let languageIso : String
    let translation : String
    let pluralForm: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case languageIso = "language_iso"
        case translation = "translation"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        languageIso = try values.decodeIfPresent(String.self, forKey: .languageIso) ?? ""
       translation = try values.decodeIfPresent(String.self, forKey: .translation) ?? ""
        if let pluralFormData = (try? values.decode(String.self, forKey: .translation))?.data(using: .utf8) {
            if let pluralFormJson = (try? JSONSerialization.jsonObject(with: pluralFormData, options: []) as? [String: String]) {
                pluralForm = pluralFormJson
            } else {
                pluralForm = [:]
            }
        } else {
            pluralForm = [:]
        }

    }
    

}

struct SupportedLanguageData : Codable {
    let languageCode : String
    let languageName : String
    let languageId : Int

    enum CodingKeys: String, CodingKey {

        case languageCode = "lang_code"
        case languageName = "lang_name"
        case languageId = "lang_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        languageCode = try values.decodeIfPresent(String.self, forKey: .languageCode) ?? "en"
        languageName = try values.decodeIfPresent(String.self, forKey: .languageName) ?? ""
        languageId = try values.decodeIfPresent(Int.self, forKey: .languageId) ?? 0
    }

}
