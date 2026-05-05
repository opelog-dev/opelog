import SwiftUI

struct OpelogTheme: Identifiable, Equatable {
    enum ThemeID: String, CaseIterable {
        case classicCream
        case softPink
        case sageGreen
        case lavender
        case minimalWhite
        case warmPeach
    }

    let id: ThemeID
    let displayName: String
    let isPremium: Bool
    let backgroundColor: Color
    let cardColor: Color
    let accentColor: Color
    let secondaryAccentColor: Color
    let primaryTextColor: Color
    let secondaryTextColor: Color
    let subtleBorderColor: Color

    var localizedDisplayName: String {
        switch id {
        case .classicCream: return L10n.themeClassicCream
        case .softPink: return L10n.themeSoftPink
        case .sageGreen: return L10n.themeSageGreen
        case .lavender: return L10n.themeLavender
        case .minimalWhite: return L10n.themeMinimalWhite
        case .warmPeach: return L10n.themeWarmPeach
        }
    }

    static let classicCream = OpelogTheme(
        id: .classicCream,
        displayName: "Classic Cream",
        isPremium: false,
        backgroundColor: Color(red: 0.98, green: 0.97, blue: 0.95),
        cardColor: Color(red: 0.98, green: 0.95, blue: 0.92),
        accentColor: Color(red: 0.72, green: 0.53, blue: 0.58),
        secondaryAccentColor: Color(red: 0.57, green: 0.66, blue: 0.58),
        primaryTextColor: Color(red: 0.18, green: 0.17, blue: 0.16),
        secondaryTextColor: Color(red: 0.41, green: 0.38, blue: 0.36),
        subtleBorderColor: Color(red: 0.88, green: 0.85, blue: 0.82)
    )

    static let softPink = OpelogTheme(
        id: .softPink,
        displayName: "Soft Pink",
        isPremium: true,
        backgroundColor: Color(red: 0.99, green: 0.95, blue: 0.96),
        cardColor: Color(red: 1.0, green: 0.98, blue: 0.98),
        accentColor: Color(red: 0.75, green: 0.56, blue: 0.62),
        secondaryAccentColor: Color(red: 0.63, green: 0.69, blue: 0.63),
        primaryTextColor: Color(red: 0.20, green: 0.18, blue: 0.19),
        secondaryTextColor: Color(red: 0.44, green: 0.40, blue: 0.42),
        subtleBorderColor: Color(red: 0.90, green: 0.84, blue: 0.86)
    )

    static let sageGreen = OpelogTheme(
        id: .sageGreen,
        displayName: "Sage Green",
        isPremium: true,
        backgroundColor: Color(red: 0.95, green: 0.98, blue: 0.95),
        cardColor: Color(red: 0.99, green: 1.0, blue: 0.98),
        accentColor: Color(red: 0.52, green: 0.64, blue: 0.56),
        secondaryAccentColor: Color(red: 0.72, green: 0.62, blue: 0.58),
        primaryTextColor: Color(red: 0.18, green: 0.21, blue: 0.18),
        secondaryTextColor: Color(red: 0.38, green: 0.44, blue: 0.39),
        subtleBorderColor: Color(red: 0.83, green: 0.88, blue: 0.84)
    )

    static let lavender = OpelogTheme(
        id: .lavender,
        displayName: "Lavender",
        isPremium: true,
        backgroundColor: Color(red: 0.96, green: 0.95, blue: 0.99),
        cardColor: Color(red: 0.99, green: 0.99, blue: 1.0),
        accentColor: Color(red: 0.63, green: 0.56, blue: 0.73),
        secondaryAccentColor: Color(red: 0.58, green: 0.66, blue: 0.64),
        primaryTextColor: Color(red: 0.19, green: 0.18, blue: 0.23),
        secondaryTextColor: Color(red: 0.41, green: 0.40, blue: 0.48),
        subtleBorderColor: Color(red: 0.84, green: 0.83, blue: 0.90)
    )

    static let minimalWhite = OpelogTheme(
        id: .minimalWhite,
        displayName: "Minimal White",
        isPremium: true,
        backgroundColor: Color(red: 0.995, green: 0.995, blue: 0.995),
        cardColor: Color(red: 1.0, green: 1.0, blue: 1.0),
        accentColor: Color(red: 0.72, green: 0.57, blue: 0.60),
        secondaryAccentColor: Color(red: 0.56, green: 0.56, blue: 0.56),
        primaryTextColor: Color(red: 0.24, green: 0.24, blue: 0.24),
        secondaryTextColor: Color(red: 0.47, green: 0.47, blue: 0.47),
        subtleBorderColor: Color(red: 0.88, green: 0.88, blue: 0.88)
    )

    static let warmPeach = OpelogTheme(
        id: .warmPeach,
        displayName: "Warm Peach",
        isPremium: true,
        backgroundColor: Color(red: 0.99, green: 0.95, blue: 0.91),
        cardColor: Color(red: 0.99, green: 0.96, blue: 0.92),
        accentColor: Color(red: 0.81, green: 0.55, blue: 0.47),
        secondaryAccentColor: Color(red: 0.63, green: 0.69, blue: 0.61),
        primaryTextColor: Color(red: 0.24, green: 0.19, blue: 0.17),
        secondaryTextColor: Color(red: 0.47, green: 0.38, blue: 0.34),
        subtleBorderColor: Color(red: 0.91, green: 0.84, blue: 0.79)
    )

    static let allThemes: [OpelogTheme] = [
        .classicCream,
        .softPink,
        .sageGreen,
        .lavender,
        .minimalWhite,
        .warmPeach
    ]

    static var freeDefault: OpelogTheme { .classicCream }

    static func resolve(id: ThemeID) -> OpelogTheme {
        allThemes.first(where: { $0.id == id }) ?? freeDefault
    }
}
