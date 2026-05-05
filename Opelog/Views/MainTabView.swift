import SwiftData
import SwiftUI
import UIKit

struct MainTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .toolbarBackground(themeManager.currentTheme.backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tabItem {
                Label(L10n.tabHome, systemImage: "house")
            }

            NavigationStack {
                ArchiveView()
            }
            .tabItem {
                Label(L10n.tabArchive, systemImage: "archivebox")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(L10n.tabSettings, systemImage: "gearshape")
            }
        }
        .tint(themeManager.currentTheme.accentColor)
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .onAppear {
            applyTabBarAppearance()
        }
        .onChange(of: themeManager.currentTheme.id) { _, _ in
            applyTabBarAppearance()
        }
        .onChange(of: purchaseManager.isPremium) { _, isPremium in
            guard purchaseManager.didResolveEntitlements else { return }
            themeManager.enforceAccess(isPremium: isPremium)
        }
        .onChange(of: purchaseManager.didResolveEntitlements) { _, didResolve in
            guard didResolve else { return }
            themeManager.enforceAccess(isPremium: purchaseManager.isPremium)
        }
        .task {
            NotificationService.requestPermissionIfNeeded()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await purchaseManager.refreshEntitlements() }
            }
        }
    }

    private func applyTabBarAppearance() {
        let theme = themeManager.currentTheme
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = UIColor.clear
        appearance.backgroundColor = UIColor(theme.backgroundColor)

        let item = UITabBarItemAppearance()
        let accent = UIColor(theme.accentColor)
        let normalLabel = UIColor(theme.secondaryTextColor)
        let normalFont = UIFont.systemFont(ofSize: 10, weight: .medium)
        let selectedFont = UIFont.systemFont(ofSize: 10, weight: .semibold)
        item.normal.titleTextAttributes = [.font: normalFont, .foregroundColor: normalLabel]
        item.selected.titleTextAttributes = [.font: selectedFont, .foregroundColor: accent]
        item.normal.iconColor = normalLabel
        item.selected.iconColor = accent

        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = accent
        UITabBar.appearance().unselectedItemTintColor = normalLabel
        UITabBar.appearance().itemPositioning = .centered
    }
}

#Preview {
    let container = try! ModelContainer(
        for: OpenItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return MainTabView()
        .environmentObject(PurchaseManager())
        .environmentObject(ThemeManager())
        .modelContainer(container)
}
