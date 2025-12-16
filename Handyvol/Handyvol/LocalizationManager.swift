import Foundation
import SwiftUI

extension Notification.Name {
    static let languageDidChange = Notification.Name("LanguageDidChangeNotification")
}

class LocalizationManager: ObservableObject {
    
    static let shared = LocalizationManager()
    
    let availableLanguages = [("ru", "Русский"), ("en", "English"), ("kk", "Қазақша")]
    
    private let userDefaultsKey = "selectedLanguageCode"

    @Published var currentLanguageCode: String
    
    init() {
        self.currentLanguageCode = UserDefaults.standard.string(forKey: userDefaultsKey) ?? "ru"
        
        self.applyLanguageSettings(code: self.currentLanguageCode)
    }

    func getCurrentLocale() -> Locale {
        return Locale(identifier: self.currentLanguageCode)
    }
    
    func setLanguage(langCode: String) {
        UserDefaults.standard.set(langCode, forKey: userDefaultsKey)
        self.currentLanguageCode = langCode
        
        self.applyLanguageSettings(code: langCode)
        
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }
    
    private func applyLanguageSettings(code: String) {
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}
