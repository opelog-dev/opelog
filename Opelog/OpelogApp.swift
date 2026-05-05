import SwiftUI
import SwiftData

@main
struct OpelogApp: App {
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject private var themeManager = ThemeManager()

    init() {
        ReminderTimeSettings.bootstrap()
        AdMobManager.configureSDKIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(purchaseManager)
                .environmentObject(themeManager)
                // Keeps system-adaptive SwiftUI/UIKit chrome in the light palette so iOS Dark Mode
                // does not flip unstyled surfaces to black. Opelog’s colors still come entirely from
                // `ThemeManager` / `OpelogTheme` (Premium theme selection & persistence unchanged).
                .preferredColorScheme(.light)
        }
        .modelContainer(for: OpenItem.self)
    }
}
