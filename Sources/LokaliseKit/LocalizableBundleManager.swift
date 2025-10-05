//
//  LocalizableBundleManager.swift
//

import Foundation

class LocalizableBundleManager {
    
    private enum LocalizableBundleType {
        case local, server
    }
    
    private let stringsLocalizableFileName = "Localizable.strings"
    private let localizableStringsDictFileName = "Localizable.stringsdict"
    private let bundleName = "LokaliseDynamic.bundle"
    private let langSuffix = ".lproj"
    private let manager = FileManager.default
    private var bundlePath: URL {
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        let bundlePath = documents.appendingPathComponent(bundleName, isDirectory: true)
        return bundlePath
    }
    var currentBundle = Bundle.main
    private var currentLoadedLocalizableBundleType: LocalizableBundleType = .local
    static let shared = LocalizableBundleManager()
    var currentLanguage: String = ""
    private init() {}
    
}

// MARK: Private Methods
private extension LocalizableBundleManager {
    
    func cleanBundleIfExist() {
        if manager.fileExists(atPath: bundlePath.path) {
            do {
                try manager.removeItem(at: bundlePath)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func setCurrentBundle(forLanguage: String) {
        do {
            currentBundle = try returnCurrentBundleForLanguage(language: forLanguage)
        } catch {
            currentBundle = Bundle(path: getPathForLocalLanguage(language: forLanguage)) ?? Bundle()
        }
    }
    
    func returnCurrentBundleForLanguage(language: String) throws -> Bundle {
        if !(manager.fileExists(atPath: bundlePath.path)) {
            return Bundle(path: getPathForLocalLanguage(language: language))!
        }
        do {
            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
            _ = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let enumerator = FileManager.default.enumerator(at: bundlePath ,
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                return true
            })!
            for case let folderURL as URL in enumerator {
                _ = try folderURL.resourceValues(forKeys: Set(resourceKeys))
                if folderURL.lastPathComponent == ("\(language)\(langSuffix)"){
                    let subfolderEnumerator = FileManager.default.enumerator(at: folderURL,
                                                                             includingPropertiesForKeys: resourceKeys,
                                                                             options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                        return true
                    })!
                    for case let fileURL as URL in subfolderEnumerator {
                        _ = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                        if fileURL.lastPathComponent == stringsLocalizableFileName {
                            currentLoadedLocalizableBundleType = .server
                            return Bundle(url: folderURL)!
                        }
                    }
                }
            }
        } catch {
            debugPrint(error.localizedDescription)
            return Bundle(path: getPathForLocalLanguage(language: language)) ?? Bundle()
        }
        return Bundle(path: getPathForLocalLanguage(language: language)) ?? Bundle()
    }
    
    func getPathForLocalLanguage(language: String, shouldSetBundleType: Bool = true) -> String {
        guard let initialPath = Bundle.main.resourcePath else {
            return ""
        }
        let languageFolder = "/\(language)\(getTargetPath())\(langSuffix)"
        if shouldSetBundleType {
            currentLoadedLocalizableBundleType = .local
        }
        return initialPath  + languageFolder
    }
    
    func getTargetPath() -> String {
        return ""
    }
    
    func writePluralsFileToBundle(localizedKey: String, languageCode: String, pluralsData: [String: String]) {
        
        var localizableFullContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
            """
        var localizableContent = """
            <key>\(localizedKey)</key>
            <dict>
                <key>NSStringLocalizedFormatKey</key>
                <string>%#@format@</string>
                <key>format</key>
                <dict>
               <key>NSStringFormatSpecTypeKey</key>
               <string>NSStringPluralRuleType</string>
               <key>NSStringFormatValueTypeKey</key>
               <string>li</string>
            """
        
        for (pluralKey, pluralValue) in pluralsData {
            localizableContent += """
                        <key>\(pluralKey)</key>
                        <string>\(pluralValue)</string>
                    """
        }
        localizableContent += """
                    </dict>
                </dict>
                </dict>
                </plist>
                """
        let languagePath = bundlePath.appendingPathComponent("\(languageCode)\(langSuffix)", isDirectory: true)
        if !(manager.fileExists(atPath: languagePath.path)) {
            do {try manager.createDirectory(at: languagePath, withIntermediateDirectories: true, attributes: [FileAttributeKey.protectionKey : FileProtectionType.complete])
            }
            catch {
                debugPrint(error.localizedDescription)
            }
        }
        let filePath = languagePath.appendingPathComponent(localizableStringsDictFileName)
        if manager.fileExists(atPath: filePath.path) {
            if var existingContent = try? String(contentsOf: filePath) {
                let plistclosingTags = "</dict>\n</plist>"
                existingContent = String(existingContent.dropLast(plistclosingTags.count))
                existingContent += localizableContent
                do {
                    try existingContent.write(to: filePath, atomically: true, encoding: .utf8)
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
        } else {
            localizableFullContent += localizableContent
            do {
                try localizableFullContent.write(to: filePath, atomically: true, encoding: .utf8)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func writeStringFileToBundle(localizedKey: String, localizedValue: String, languageCode: String) {
        
        if !(manager.fileExists(atPath: bundlePath.path)) {
            do {
                try manager.createDirectory(at: bundlePath, withIntermediateDirectories: true, attributes: [FileAttributeKey.protectionKey : FileProtectionType.complete])
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        let languagePath = bundlePath.appendingPathComponent("\(languageCode)\(langSuffix)", isDirectory: true)
        if !(manager.fileExists(atPath: languagePath.path)) {
            do {
                try manager.createDirectory(at: languagePath, withIntermediateDirectories: true, attributes: [FileAttributeKey.protectionKey : FileProtectionType.complete])
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        
        let escapedValue = localizedValue.replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let localizedString = "\"\(localizedKey)\" = \"\(escapedValue)\";\n"
        let filePath = languagePath.appendingPathComponent(stringsLocalizableFileName)
        let localizedData = localizedString.data(using: .utf8) ?? Data()
        if !manager.fileExists(atPath: filePath.path) {
            manager.createFile(atPath: filePath.path, contents: nil, attributes: [FileAttributeKey.protectionKey : FileProtectionType.complete])
        }
        
        do {
            let fileHandle = try FileHandle(forWritingTo: filePath)
            fileHandle.seekToEndOfFile()
            fileHandle.write(localizedData)
            fileHandle.closeFile()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
}

// MARK: Public Methods
extension LocalizableBundleManager {
    
    func getLocalBundle() -> Bundle {
        return Bundle(path: getPathForLocalLanguage(language: LocalizableBundleManager.shared.currentLanguage , shouldSetBundleType : false)) ?? Bundle()
    }
    
    func isLocalLocalizableBundleIsLoaded() -> Bool {
        return currentLoadedLocalizableBundleType == .local
    }
    
    func writeLocalizationDataToBundle(localizeKeysData: [LocalisationKeys], _ success: @escaping () -> Void) {
        guard !localizeKeysData.isEmpty else {
            success()
            return
        }
        
        cleanBundleIfExist()
        localizeKeysData
            .forEach { languageObject in
                // Pick the translation for the currently selected language instead of assuming the first item matches.
                guard let translationObject = languageObject.translations?
                    .first(where: { $0.languageIso == LocalizableBundleManager.shared.currentLanguage })
                else { return }
                let localizedKey = languageObject.localiseKeyName
                let localizedValue = translationObject.translation
                let languageCode = translationObject.languageIso
                if languageObject.isPlural {
                    let pluralFormData = translationObject.pluralForm
                    writePluralsFileToBundle(localizedKey: localizedKey, languageCode: languageCode, pluralsData: pluralFormData)
                } else {
                    writeStringFileToBundle(localizedKey: localizedKey, localizedValue: localizedValue, languageCode: languageCode)
                }
            }
        self.setCurrentBundle(forLanguage: LocalizableBundleManager.shared.currentLanguage)
        success()
    }
    
}
