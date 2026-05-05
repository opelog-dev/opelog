import Foundation
import GoogleMobileAds

/// One-time Mobile Ads SDK startup. Call early from `OpelogApp` (no StoreKit / Firebase / analytics here).
enum AdMobManager {
    private static var didStartSDK = false

    static func configureSDKIfNeeded() {
        guard !didStartSDK else { return }

        // SwiftUI previews use a lightweight host; `GADApplicationIdentifier` is often absent → skip SDK there.
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }

        didStartSDK = true

        applyLightweightPrivacyDefaults()

        MobileAds.shared.start(completionHandler: nil)
    }

    /// No ATT, no UMP, no custom ad targeting in this build — only conservative SDK defaults where available.
    private static func applyLightweightPrivacyDefaults() {
        MobileAds.shared.requestConfiguration.maxAdContentRating = .general
    }
}
