import SwiftUI

/// Lifetime Premium paywall — soft lifestyle tone, no urgency or fake scarcity.
struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var themeManager: ThemeManager

    /// When `true`, show the free-tier item limit explanation (e.g. opened from add flow at cap).
    var emphasizesItemLimit: Bool = false

    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    if emphasizesItemLimit {
                        limitCallout
                    }

                    benefitsCard

                    VStack(spacing: 12) {
                        purchaseButton
                        if purchaseManager.premiumProduct == nil, !purchaseManager.isPremium, !purchaseManager.isLoadingProduct {
                            Text(L10n.premiumStoreUnavailable)
                                .font(.footnote)
                                .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        restoreButton
                    }

                    Text(L10n.premiumOnetimeNote)
                        .font(.footnote)
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
            .background(themeManager.currentTheme.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.premiumClose) {
                        dismiss()
                    }
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                }
            }
        }
        .tint(themeManager.currentTheme.accentColor)
        .task {
            await purchaseManager.loadPremiumProduct()
        }
        .alert(L10n.premiumTitle, isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button(L10n.actionOK) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .font(.title2.weight(.light))
                    .foregroundStyle(themeManager.currentTheme.accentColor.opacity(0.85))
                Text(L10n.premiumTitle)
                    .font(.largeTitle.weight(.bold))
            }
            Text(L10n.premiumSubtitle)
                .font(.body)
                .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var limitCallout: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.premiumLimitLine1)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(themeManager.currentTheme.primaryTextColor)
            Text(L10n.premiumLimitLine2)
                .font(.subheadline)
                .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                .lineSpacing(3)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opelogCardChrome(cornerRadius: AppTheme.panelCorner)
    }

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            benefitRow(icon: "infinity", text: L10n.premiumBenefitItems)
            benefitRow(icon: "eye.slash", text: L10n.premiumBenefitNoAds)
            benefitRow(icon: "archivebox", text: L10n.premiumBenefitArchive)
            benefitRow(icon: "paintpalette", text: L10n.premiumBenefitTheme)
            benefitRow(icon: "photo.stack", text: L10n.premiumBenefitMultiplePhotos)
            benefitRow(icon: "sparkles", text: L10n.premiumBenefitFuture)

            Text(L10n.premiumBenefitMultiplePhotosDetail)
                .font(.footnote)
                .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                .lineSpacing(2)
                .padding(.top, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opelogCardChrome(cornerRadius: AppTheme.cardCorner)
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(themeManager.currentTheme.accentColor.opacity(0.9))
                .frame(width: 26, alignment: .center)
            Text(text)
                .font(.body)
                .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
    }

    private var purchaseButton: some View {
        Button {
            Task { await runPurchase() }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                }
                Text(purchaseManager.isPremium ? L10n.premiumAlreadyPremium : L10n.premiumUnlockButton)
                    .font(.headline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(themeManager.currentTheme.accentColor)
        .disabled(isPurchasing || isRestoring || purchaseManager.isPremium || purchaseManager.premiumProduct == nil)
    }

    private var restoreButton: some View {
        Button {
            Task { await runRestore() }
        } label: {
            HStack {
                if isRestoring {
                    ProgressView()
                }
                Text(L10n.premiumRestoreButton)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .disabled(isPurchasing || isRestoring)
    }

    @MainActor
    private func runPurchase() async {
        if purchaseManager.isPremium {
            alertMessage = L10n.premiumAlreadyPremium
            return
        }
        isPurchasing = true
        defer { isPurchasing = false }
        let outcome = await purchaseManager.purchasePremium()
        switch outcome {
        case .purchased:
            dismiss()
        case .userCancelled:
            break
        case .pending:
            alertMessage = L10n.premiumPending
        case .failedUserMessage(let msg):
            alertMessage = msg
        }
    }

    @MainActor
    private func runRestore() async {
        isRestoring = true
        defer { isRestoring = false }
        let outcome = await purchaseManager.restorePurchases()
        switch outcome {
        case .restoredPremium:
            alertMessage = L10n.premiumRestoreSuccess
        case .nothingFound:
            alertMessage = L10n.premiumRestoreEmpty
        case .failedUserMessage(let msg):
            alertMessage = msg
        }
    }
}

#Preview("Paywall") {
    PremiumView(emphasizesItemLimit: true)
        .environmentObject(PurchaseManager())
        .environmentObject(ThemeManager())
}
