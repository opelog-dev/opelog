import Foundation

/// AdMob identifiers and test vs production banner slot. **Premium / ad visibility** is driven by `PurchaseManager.isPremium`, not here.
enum AdConfig {
    // MARK: - AdMob application ID (`Opelog/Info.plist` → `GADApplicationIdentifier`)

    /// Opelog production **app ID** (must match `GADApplicationIdentifier` in `Opelog/Info.plist`).
    static let productionApplicationIdentifier = "ca-app-pub-9878918764981841~7309689587"

    /// Google sample **app ID** (only needed if you point `Info.plist` at it while using `googleTestBannerAdUnitID`).
    static let googleSampleApplicationIdentifier = "ca-app-pub-3940256099942544~1458002511"

    // MARK: - Banner ad unit

    /// Opelog production **banner** ad unit ID from AdMob (the value with `/`).
    static let productionBannerAdUnitID = "ca-app-pub-9878918764981841/5372739037"

    /// Google’s official iOS **test** banner unit (test creatives only).
    static let googleTestBannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"

    #if DEBUG
    static let useGoogleTestBannerUnit: Bool = true
    #else
    static let useGoogleTestBannerUnit: Bool = false
    #endif

    /// Banner slot passed to `BannerView`.
    static var bannerAdUnitID: String {
        useGoogleTestBannerUnit ? googleTestBannerAdUnitID : productionBannerAdUnitID
    }
}
