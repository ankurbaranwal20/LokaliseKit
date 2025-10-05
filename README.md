# LokaliseKit

A lightweight Swift Package that fetches remote localization JSON and loads it into a dynamic bundle so you can localize strings at runtime. Includes convenient `String.localized()` helpers and a one-liner initialize API.

## Requirements

- iOS 13+
- Swift 5.9+

## Installation

### Option A: Local package
1. In Xcode, go to: File → Add Packages…
2. Click "Add Local…" and select the `LokaliseKit/` directory.
3. Add the product `LokaliseKit` to your app target.

### Option B: Git (recommended for reuse across repos)
1. Push this package to a Git repository.
2. In Xcode: File → Add Packages…
3. Enter the Git URL and pick a version or main branch.
4. Add the product `LokaliseKit` to your app target.

## Quick Start

### One-liner init
```swift
import LokaliseKit

LokaliseKit.initialize(urlString: "https://example.com/en.json", languageCode: "en") {
    // Dynamic localizations are ready
    print("welcome_title".localized())
}
```

### Or use the ViewModel directly
```swift
import LokaliseKit

let vm = LocalizationViewModel()
vm.getLocalizationData(urlString: "https://example.com/en.json", currentLanguageCode: "en") {
    print("general_history_trans_undefined".localized())
}
```

### Formatting placeholders
```swift
// If your server value contains %s or [%s], they will be normalized to %@
print("items_count".localizedFormatted(3) ?? "")
```

## How it works
- Downloads your JSON and decodes it to `LocalizationModel`.
- Writes strings/plurals into `Documents/LokaliseDynamic.bundle/<lang>.lproj/`.
- Sets the active `Bundle` to the dynamic one for the selected language.
- `String.localized()` reads from the dynamic bundle first, and falls back to your app’s local `Localizable.strings` if the key is missing.

## API Surface
- `LokaliseKit.initialize(urlString:languageCode:completion:)`
- `LocalizationViewModel.getLocalizationData(urlString:currentLanguageCode:completion:)`
- `String.localized(...)`
- `String.localizedFormatted(...)`

## Notes
- Call initialize once per language or on app launch as needed.
- Keep your app’s local `Localizable.strings` files for fallback translations.
- If your endpoint needs headers (e.g., API token), extend `LokalizationService` to set them on the URLRequest.

## License
MIT (add your preferred license here)
