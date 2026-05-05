import SwiftData
import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showPremiumSheet = false
    @State private var notificationAuthorization: UNAuthorizationStatus = .notDetermined

    @AppStorage("opelog.defaultReminderHour") private var reminderHour = 10
    @AppStorage("opelog.defaultReminderMinute") private var reminderMinute = 0

    @Query(filter: #Predicate<OpenItem> { !$0.isArchived && $0.notificationEnabled }) private var notifiableActiveItems: [OpenItem]

    var body: some View {
        List {
            Section {
                Text(L10n.tabSettings)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .listRowInsets(EdgeInsets(top: AppTheme.settingsTabRootTitleListRowTopInset, leading: 22, bottom: 12, trailing: 22))
                    .listRowBackground(themeManager.currentTheme.backgroundColor)
                    .listRowSeparator(.hidden)
            }

            Section {
                if purchaseManager.isPremium {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.settingsCurrentPlan)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        Text(L10n.settingsPlanPremium)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(themeManager.currentTheme.secondaryAccentColor)

                        Text(L10n.settingsPremiumThanks)
                            .font(.body)
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                            .lineSpacing(4)

                        Button {
                            Task {
                                _ = await purchaseManager.restorePurchases()
                                await purchaseManager.refreshEntitlements()
                            }
                        } label: {
                            Text(L10n.premiumRestoreButton)
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.settingsCurrentPlan)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        Text(L10n.settingsPlanFree)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                        Text(L10n.settingsPremiumPitch)
                            .font(.subheadline)
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                            .lineSpacing(4)

                        Button {
                            showPremiumSheet = true
                        } label: {
                            Text(L10n.settingsUpgradeButton)
                                .font(.headline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(themeManager.currentTheme.accentColor)
                        .padding(.top, 2)
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
                }
            } header: {
                sectionTitle(L10n.settingsSectionPremium)
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(L10n.currentTheme)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        Spacer()
                        Text(themeManager.currentTheme.localizedDisplayName)
                            .font(.subheadline)
                            .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                    }

                    NavigationLink {
                        ThemeSelectionView()
                            .environmentObject(purchaseManager)
                            .environmentObject(themeManager)
                    } label: {
                        HStack {
                            Text(L10n.changeTheme)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                        }
                        .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.plain)

                    if !purchaseManager.isPremium {
                        Text(L10n.settingsThemeUnlockHint)
                            .font(.footnote)
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(OpelogTheme.allThemes.filter(\.isPremium)) { theme in
                                    Button {
                                        showPremiumSheet = true
                                    } label: {
                                        ThemePreviewCard(theme: theme, isSelected: false, isLocked: true)
                                            .frame(minWidth: 132, idealWidth: 156, maxWidth: 220)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
            } header: {
                sectionTitle(L10n.settingsSectionTheme)
            }

            Section {
                Text(L10n.settingsNotificationsIntro)
                    .font(.body)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .lineSpacing(4)

                DatePicker(selection: reminderTimeBinding, displayedComponents: .hourAndMinute) {
                    Text(L10n.reminderTimeLabel)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                }
                .padding(.top, 4)
                .onChange(of: reminderHour) { _, _ in rescheduleNotifiableReminders() }
                .onChange(of: reminderMinute) { _, _ in rescheduleNotifiableReminders() }

                Text(L10n.settingsReminderTimeHint)
                    .font(.footnote)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .lineSpacing(3)
                    .padding(.top, 2)

                if notificationAuthorization == .denied || notificationAuthorization == .ephemeral {
                    Text(L10n.settingsNotificationsDeniedHint)
                        .font(.footnote)
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        .lineSpacing(3)
                        .padding(.top, 2)
                }

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label(L10n.openAppSettingsButton, systemImage: "gear")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
            } header: {
                sectionTitle(L10n.settingsSectionNotifications)
            }

            Section {
                Text(L10n.settingsDisplayBody)
                    .font(.body)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .lineSpacing(4)
                    .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))

                if !purchaseManager.isPremium {
                    Text(L10n.adsRemoveWithPremium)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                        .padding(.top, 6)
                    Text(L10n.adsHiddenForPremium)
                        .font(.footnote)
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        .lineSpacing(3)
                } else {
                    Text(L10n.adsHiddenForPremium)
                        .font(.footnote)
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        .lineSpacing(3)
                        .padding(.top, 4)
                }
            } header: {
                sectionTitle(L10n.settingsSectionDisplay)
            }

            Section {
                Text(L10n.settingsPrivacyCombinedBody)
                    .font(.body)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .lineSpacing(4)
                    .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
            } header: {
                sectionTitle(L10n.settingsSectionDataPrivacy)
            }

            Section {
                Text(L10n.settingsSupportPlaceholder)
                    .font(.body)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .lineSpacing(4)
                    .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
            } header: {
                sectionTitle(L10n.settingsSectionSupport)
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.appName)
                        .font(.title2.weight(.semibold))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.settingsVersionLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        Text(versionLine)
                            .font(.footnote)
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    }

                    Text(L10n.taglineAbout)
                        .font(.body)
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        .lineSpacing(4)

                    Text(L10n.taglineSub)
                        .font(.subheadline)
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.9))
                        .lineSpacing(3)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.settingsPrivacyPolicy)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(themeManager.currentTheme.accentColor)
                        Text(L10n.settingsTermsOfUse)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(themeManager.currentTheme.accentColor)
                        Text(L10n.settingsContactSupport)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(themeManager.currentTheme.accentColor)
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 8)
                .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
            } header: {
                sectionTitle(L10n.settingsSectionAbout)
            }
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.currentTheme.backgroundColor)
        .listRowBackground(themeManager.currentTheme.cardColor)
        .listSectionSpacing(14)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .tint(themeManager.currentTheme.accentColor)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            OpelogBottomBannerInset()
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumView(emphasizesItemLimit: false)
                .environmentObject(purchaseManager)
                .environmentObject(themeManager)
        }
        .task {
            await refreshNotificationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task { await refreshNotificationStatus() }
        }
    }

    private var versionLine: String {
        let bundle = Bundle.main
        let v = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let b = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        if let b, b != v {
            return L10n.appVersionDetail(version: v, build: b)
        }
        return L10n.appVersionShort(version: v)
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                c.hour = reminderHour
                c.minute = reminderMinute
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = min(23, max(0, c.hour ?? reminderHour))
                reminderMinute = min(59, max(0, c.minute ?? reminderMinute))
            }
        )
    }

    private func rescheduleNotifiableReminders() {
        for item in notifiableActiveItems {
            NotificationService.refreshReminder(for: item)
        }
    }

    @MainActor
    private func refreshNotificationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        notificationAuthorization = settings.authorizationStatus
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.92))
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

#Preview {
    let container = try! ModelContainer(for: OpenItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    return NavigationStack {
        SettingsView()
            .environmentObject(PurchaseManager())
            .environmentObject(ThemeManager())
    }
    .modelContainer(container)
}
