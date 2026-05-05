import SwiftUI

enum AppTheme {
    static let cardCorner: CGFloat = 20
    static let panelCorner: CGFloat = 18
    static let heroCorner: CGFloat = 24
    /// Home & archive list thumbnails (rounded square).
    static let cardThumbnailSize: CGFloat = 60
    static let cardThumbnailCorner: CGFloat = 16

    /// Item detail hero thumbnail (rounded square).
    static let detailHeroThumbSize: CGFloat = 92
    static let detailHeroThumbCorner: CGFloat = 24

    static let sectionSpacing: CGFloat = 28
    static let stackTight: CGFloat = 10
    static let stackComfortable: CGFloat = 14

    /// Finished Log (`ScrollView`): top padding before the in-content `.largeTitle` (no `List` extras).
    static let tabRootLargeTitleSubstituteTopInset: CGFloat = 68

    /// Settings title row (`List`): `List` already adds top safe-area / content margin, so this inset
    /// is **smaller** than `tabRootLargeTitleSubstituteTopInset` so the title lines up with Finished Log.
    static let settingsTabRootTitleListRowTopInset: CGFloat = 28

    static let cardPaddingH: CGFloat = 22
    static let cardPaddingV: CGFloat = 20

    static func statusLabelColors(for status: ItemStatus, theme: OpelogTheme) -> (foreground: Color, background: Color) {
        switch status {
        case .good:
            return (
                theme.secondaryAccentColor.opacity(0.95),
                theme.secondaryAccentColor.opacity(0.2)
            )
        case .soon:
            return (
                theme.accentColor.opacity(0.92),
                theme.accentColor.opacity(0.17)
            )
        case .expired:
            return (
                theme.secondaryTextColor.opacity(0.94),
                theme.secondaryTextColor.opacity(0.16)
            )
        }
    }

    static func remainingAccent(for status: ItemStatus, theme: OpelogTheme) -> Color {
        switch status {
        case .good: return theme.secondaryAccentColor
        case .soon: return theme.accentColor
        case .expired: return theme.secondaryTextColor
        }
    }

    static let cardShadowColor = Color.black.opacity(0.04)
    static let cardShadowRadius: CGFloat = 12
    static let cardShadowY: CGFloat = 4

    static func placeholderOrbFill(status: ItemStatus, neutral: Bool, theme: OpelogTheme) -> Color {
        if neutral {
            return theme.secondaryTextColor.opacity(0.14)
        }
        switch status {
        case .good: return theme.secondaryAccentColor.opacity(0.2)
        case .soon: return theme.accentColor.opacity(0.18)
        case .expired: return theme.secondaryTextColor.opacity(0.16)
        }
    }
}

extension View {
    func opelogCardChrome(cornerRadius: CGFloat = AppTheme.cardCorner) -> some View {
        modifier(OpelogCardChromeModifier(cornerRadius: cornerRadius))
    }
}

private struct OpelogCardChromeModifier: ViewModifier {
    @EnvironmentObject private var themeManager: ThemeManager
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(themeManager.currentTheme.cardColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(themeManager.currentTheme.subtleBorderColor, lineWidth: 1)
            )
            .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: AppTheme.cardShadowY)
    }
}
