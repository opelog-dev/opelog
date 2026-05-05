import SwiftData
import SwiftUI

private enum ArchiveFilter: String, CaseIterable, Identifiable {
    case all
    case favorites
    case buyAgain
    case doNotBuyAgain

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return L10n.repurchaseFilterAll
        case .favorites: return L10n.repurchaseFilterFavorites
        case .buyAgain: return L10n.repurchaseFilterBuyAgain
        case .doNotBuyAgain: return L10n.repurchaseFilterDoNotBuyAgain
        }
    }
}

struct ArchiveView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Query(
        filter: #Predicate<OpenItem> { $0.isArchived },
        sort: [
            SortDescriptor(\OpenItem.finishedDate, order: .reverse),
            SortDescriptor(\OpenItem.createdAt, order: .reverse)
        ]
    )
    private var archivedItems: [OpenItem]
    @State private var filter: ArchiveFilter = .all
    @State private var photoViewer: PhotoViewerPayload?

    private var filteredArchivedItems: [OpenItem] {
        switch filter {
        case .all:
            return archivedItems
        case .favorites:
            return archivedItems.filter(\.isFavorite)
        case .buyAgain:
            return archivedItems.filter { $0.repurchaseStatus == .buyAgain }
        case .doNotBuyAgain:
            return archivedItems.filter { $0.repurchaseStatus == .doNotBuyAgain }
        }
    }

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor
                .ignoresSafeArea()

            if archivedItems.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        archiveScreenHeading

                        summarySection
                        filterSection

                        if filteredArchivedItems.isEmpty {
                            filteredEmptyState
                        } else {
                            ForEach(filteredArchivedItems) { item in
                                archivedCard(item)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, AppTheme.tabRootLargeTitleSubstituteTopInset)
                    .padding(.bottom, 36)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .tint(themeManager.currentTheme.accentColor)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            OpelogBottomBannerInset()
        }
        .fullScreenCover(item: $photoViewer) { payload in
            PhotoViewerView(fileNames: payload.fileNames, startIndex: payload.startIndex)
        }
    }

    private var archiveScreenHeading: some View {
        Text(L10n.finishedLogNavigationTitle)
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(themeManager.currentTheme.primaryTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }

    private var emptyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                archiveScreenHeading
                    .padding(.horizontal, 22)
                    .padding(.top, AppTheme.tabRootLargeTitleSubstituteTopInset)
                    .padding(.bottom, 16)

                VStack(spacing: 18) {
                    Spacer()
                        .frame(minHeight: 16, maxHeight: 32)

                    ZStack {
                        Circle()
                            .fill(themeManager.currentTheme.accentColor.opacity(0.2))
                            .frame(width: 88, height: 88)
                        Image(systemName: "archivebox")
                            .font(.system(size: 28, weight: .ultraLight))
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.9))
                    }

                    VStack(spacing: 8) {
                        Text(L10n.finishedLogEmptyTitle)
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text(L10n.finishedLogEmptySubtitle)
                            .font(.subheadline)
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 22)

                Spacer(minLength: 48)
            }
        }
    }

    private var filteredEmptyState: some View {
        VStack(spacing: 10) {
            Text(filter.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
            Text(L10n.archiveFilteredEmptyHint)
                .font(.caption)
                .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(themeManager.currentTheme.cardColor.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(themeManager.currentTheme.subtleBorderColor.opacity(0.7), lineWidth: 1)
        )
    }

    private var summarySection: some View {
        HStack(spacing: 10) {
            summaryCapsule(L10n.finishedSummaryCount(totalFinishedCount))
            summaryCapsule(L10n.finishedSummaryAverage(averageUsageDays(for: filteredArchivedItems)))
            summaryCapsule(L10n.finishedSummaryLongest(longestUsageDays(for: filteredArchivedItems)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: summaryAnimationKey)
    }

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ArchiveFilter.allCases) { option in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            filter = option
                        }
                    } label: {
                        Text(option.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(
                                option == filter
                                    ? AnyShapeStyle(themeManager.currentTheme.accentColor)
                                    : AnyShapeStyle(themeManager.currentTheme.secondaryTextColor)
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(themeManager.currentTheme.cardColor.opacity(0.95))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        option == filter
                                            ? themeManager.currentTheme.accentColor.opacity(0.7)
                                            : themeManager.currentTheme.subtleBorderColor.opacity(0.8),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func summaryCapsule(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.85)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(themeManager.currentTheme.cardColor.opacity(0.95))
            )
            .overlay(
                Capsule()
                    .stroke(themeManager.currentTheme.subtleBorderColor.opacity(0.8), lineWidth: 1)
            )
    }

    private func archivedCard(_ item: OpenItem) -> some View {
        HStack(alignment: .center, spacing: 14) {
            OpelogPhotoThumbnailButton(
                displayFileName: item.primaryImageFileName,
                category: item.category,
                status: item.status,
                sideLength: AppTheme.cardThumbnailSize,
                cornerRadius: AppTheme.cardThumbnailCorner,
                neutralPlaceholder: item.primaryImageFileName == nil,
                resolvedFileNames: item.resolvedImageFileNames,
                onOpenViewer: {
                    photoViewer = PhotoViewerPayload(
                        fileNames: item.resolvedImageFileNames,
                        startIndex: 0
                    )
                }
            )

            NavigationLink {
                ItemDetailView(item: item)
            } label: {
                archivedCardMainColumn(item)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .opelogCardChrome(cornerRadius: AppTheme.cardCorner)
        .opelogPinnedCardAccent(category: item.category)
    }

    private func archivedCardMainColumn(_ item: OpenItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(item.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                    .lineLimit(2)

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.45))
            }

            Text(L10n.category(storedKey: item.category))
                .font(.caption.weight(.medium))
                .foregroundStyle(themeManager.currentTheme.secondaryTextColor)

            HStack(spacing: 6) {
                if item.isFavorite {
                    badge(L10n.favoriteBadge, tint: themeManager.currentTheme.accentColor)
                }
                if item.repurchaseStatus == .buyAgain {
                    badge(L10n.repurchaseStatus(.buyAgain), tint: themeManager.currentTheme.secondaryAccentColor)
                } else if item.repurchaseStatus == .doNotBuyAgain {
                    badge(L10n.repurchaseStatus(.doNotBuyAgain), tint: themeManager.currentTheme.secondaryTextColor)
                }
            }

            Text(usagePeriodText(for: item))
                .font(.caption.weight(.medium))
                .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.9))

            Text(usageDaysText(for: item))
                .font(.title3.weight(.semibold))
                .foregroundStyle(themeManager.currentTheme.secondaryAccentColor)
                .padding(.top, 2)

            if !item.memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(L10n.memoWithLabel(memo: item.memo))
                    .font(.caption)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.9))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var totalFinishedCount: Int {
        filteredArchivedItems.count
    }

    private var summaryAnimationKey: String {
        let avg = averageUsageDays(for: filteredArchivedItems)
        let longest = longestUsageDays(for: filteredArchivedItems)
        return "\(filter.rawValue)-\(totalFinishedCount)-\(avg)-\(longest)"
    }

    private func badge(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(tint.opacity(0.14))
            )
    }

    private func usageDays(for item: OpenItem) -> Int {
        DateUtils.usageDays(openedDate: item.openedDate, finishedDate: item.finishedDate)
    }

    private func usageDaysText(for item: OpenItem) -> String {
        L10n.usedForDays(usageDays(for: item))
    }

    private func usagePeriodText(for item: OpenItem) -> String {
        let opened = DateUtils.archiveScanDate(item.openedDate)
        let finished = DateUtils.archiveScanDate(item.finishedDate ?? item.openedDate)
        return L10n.finishedPeriod(opened: opened, finished: finished)
    }

    private func averageUsageDays(for items: [OpenItem]) -> Int {
        guard !items.isEmpty else { return 0 }
        let sum = items.reduce(0) { $0 + usageDays(for: $1) }
        return Int((Double(sum) / Double(items.count)).rounded())
    }

    private func longestUsageDays(for items: [OpenItem]) -> Int {
        items.map(usageDays(for:)).max() ?? 0
    }
}

#Preview {
    let container = try! ModelContainer(
        for: OpenItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return NavigationStack {
        ArchiveView()
            .environmentObject(PurchaseManager())
            .environmentObject(ThemeManager())
    }
    .modelContainer(container)
}
