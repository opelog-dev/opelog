import GoogleMobileAds
import SwiftUI
import UIKit

// MARK: - SwiftUI inset (Home / Archive tab roots only)

/// Bottom banner row: soft background, collapses to zero height if the ad fails or Premium hides ads.
struct OpelogBottomBannerInset: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        Group {
            if !purchaseManager.isPremium {
                OpelogBannerAdRow()
            }
        }
    }
}

// MARK: - Width + state

private struct OpelogBannerAdRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var didFail = false

    private var bannerWidth: CGFloat {
        max(320, OpelogWindowMetrics.bannerContainerWidth)
    }

    /// Non-zero before load: `BannerView` often needs a real layout size to fill; height 0 can prevent test ads from appearing.
    private var slotHeight: CGFloat {
        currentOrientationAnchoredAdaptiveBanner(width: bannerWidth).size.height
    }

    var body: some View {
        Group {
            if !didFail {
                BannerAdView(
                    containerWidth: bannerWidth,
                    onFailed: { didFail = true }
                )
                .frame(width: bannerWidth, height: slotHeight)
            }
        }
        .frame(height: didFail ? 0 : slotHeight)
        .frame(maxWidth: .infinity)
        .background(didFail ? Color.clear : themeManager.currentTheme.backgroundColor)
        .overlay(alignment: .top) {
            if !didFail {
                Rectangle()
                    .fill(themeManager.currentTheme.subtleBorderColor.opacity(0.55))
                    .frame(height: 0.5)
            }
        }
    }
}

// MARK: - UIViewRepresentable

private struct BannerAdView: UIViewRepresentable {
    let containerWidth: CGFloat
    let onFailed: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> BannerView {
        let width = max(320, containerWidth)
        // Softer footprint than `largeAnchoredAdaptiveBanner` (often ~2× taller; better for games).
        // Still the recommended anchored adaptive pattern for tab bars; migrate to large variant only if you explicitly want taller/video-ready slots later.
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: width)
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = AdConfig.bannerAdUnitID
        banner.delegate = context.coordinator
        // Do not call `load` here: `rootViewController` is set in `updateUIView` after the window exists.
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        let root = UIApplication.opelogKeyWindow?.rootViewController?.opelogTopMost
        uiView.rootViewController = root

        guard root != nil else { return }
        let coordinator = context.coordinator
        guard !coordinator.didStartLoad else { return }
        coordinator.didStartLoad = true
        uiView.load(Request())
    }

    final class Coordinator: NSObject, BannerViewDelegate {
        private let parent: BannerAdView
        var didStartLoad = false

        init(parent: BannerAdView) {
            self.parent = parent
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {}

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            bannerView.isHidden = true
            parent.onFailed()
        }
    }
}

// MARK: - Window / hierarchy helpers

private enum OpelogWindowMetrics {
    static var bannerContainerWidth: CGFloat {
        if let w = UIApplication.opelogKeyWindow?.bounds.width, w > 1 {
            return w
        }
        return UIScreen.main.bounds.width
    }
}

private extension UIApplication {
    /// SwiftUI / multi-window safe: `isKeyWindow` alone is sometimes nil during first layout.
    static var opelogKeyWindow: UIWindow? {
        for scene in shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            guard windowScene.activationState == .foregroundActive else { continue }
            if let key = windowScene.keyWindow { return key }
            if let marked = windowScene.windows.first(where: { $0.isKeyWindow }) { return marked }
            if let any = windowScene.windows.first { return any }
        }
        return shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }
}

private extension UIViewController {
    var opelogTopMost: UIViewController {
        if let presented = presentedViewController {
            return presented.opelogTopMost
        }
        if let nav = self as? UINavigationController, let visible = nav.visibleViewController {
            return visible.opelogTopMost
        }
        if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
            return selected.opelogTopMost
        }
        return self
    }
}
