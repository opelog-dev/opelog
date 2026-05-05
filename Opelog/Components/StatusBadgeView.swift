import SwiftUI

struct StatusBadgeView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let status: ItemStatus
    var style: Style = .compact

    enum Style {
        /// Default list / small surfaces.
        case compact
        /// Home item card — smaller, sits with category meta.
        case card
        case hero
    }

    var body: some View {
        let colors = AppTheme.statusLabelColors(for: status, theme: themeManager.currentTheme)
        Text(L10n.status(status))
            .font(font)
            .tracking(tracking)
            .foregroundStyle(colors.foreground)
            .padding(.horizontal, padH)
            .padding(.vertical, padV)
            .background(colors.background)
            .clipShape(Capsule())
    }

    private var font: Font {
        switch style {
        case .hero: return .subheadline.weight(.medium)
        case .compact: return .caption.weight(.medium)
        case .card: return .caption2.weight(.semibold)
        }
    }

    private var tracking: CGFloat {
        switch style {
        case .hero: return 0.12
        case .compact: return 0.1
        case .card: return 0.06
        }
    }

    private var padH: CGFloat {
        switch style {
        case .hero: return 13
        case .compact: return 10
        case .card: return 8
        }
    }

    private var padV: CGFloat {
        switch style {
        case .hero: return 7
        case .compact: return 5
        case .card: return 3
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusBadgeView(status: .good)
        StatusBadgeView(status: .soon, style: .card)
        StatusBadgeView(status: .soon, style: .hero)
        StatusBadgeView(status: .expired)
    }
    .environmentObject(ThemeManager())
    .padding()
    .background(OpelogTheme.freeDefault.backgroundColor)
}
