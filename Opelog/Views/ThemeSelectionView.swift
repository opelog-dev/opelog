import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showPremiumSheet = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(OpelogTheme.allThemes) { theme in
                    Button {
                        handleTap(theme)
                    } label: {
                        ThemePreviewCard(
                            theme: theme,
                            isSelected: themeManager.currentTheme.id == theme.id,
                            isLocked: theme.isPremium && !purchaseManager.isPremium
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle(L10n.themes)
        .navigationBarTitleDisplayMode(.inline)
        .tint(themeManager.currentTheme.accentColor)
        .sheet(isPresented: $showPremiumSheet) {
            PremiumView(emphasizesItemLimit: false)
                .environmentObject(purchaseManager)
                .environmentObject(themeManager)
        }
    }

    private func handleTap(_ theme: OpelogTheme) {
        if themeManager.canUseTheme(theme, isPremium: purchaseManager.isPremium) {
            themeManager.selectTheme(theme, isPremium: purchaseManager.isPremium)
        } else {
            showPremiumSheet = true
        }
    }
}

#Preview {
    NavigationStack {
        ThemeSelectionView()
            .environmentObject(PurchaseManager())
            .environmentObject(ThemeManager())
    }
}
