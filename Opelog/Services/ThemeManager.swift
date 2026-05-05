import Foundation
import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    private enum StorageKey {
        static let selectedThemeID = "selected_theme_id"
    }

    @Published private(set) var selectedThemeID: OpelogTheme.ThemeID

    init() {
        let raw = UserDefaults.standard.string(forKey: StorageKey.selectedThemeID)
        selectedThemeID = OpelogTheme.ThemeID(rawValue: raw ?? "") ?? .classicCream
    }

    var currentTheme: OpelogTheme {
        OpelogTheme.resolve(id: selectedThemeID)
    }

    func selectTheme(_ theme: OpelogTheme, isPremium: Bool) {
        guard canUseTheme(theme, isPremium: isPremium) else { return }
        selectedThemeID = theme.id
        UserDefaults.standard.set(theme.id.rawValue, forKey: StorageKey.selectedThemeID)
    }

    func canUseTheme(_ theme: OpelogTheme, isPremium: Bool) -> Bool {
        !theme.isPremium || isPremium
    }

    func enforceAccess(isPremium: Bool) {
        let selected = currentTheme
        guard !selected.isPremium || isPremium else {
            selectedThemeID = .classicCream
            UserDefaults.standard.set(OpelogTheme.freeDefault.id.rawValue, forKey: StorageKey.selectedThemeID)
            return
        }
    }
}
