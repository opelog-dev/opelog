import SwiftData
import SwiftUI

private enum HomePresentedSheet: String, Identifiable {
    case addItem
    case premium
    var id: String { rawValue }
}

enum HomeSortOption: String, CaseIterable, Identifiable {
    case recentlyAdded
    case checkSoonest
    case openedNewest
    case openedOldest

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .recentlyAdded: return L10n.homeSortRecentCreated
        case .checkSoonest: return L10n.homeSortCheckSoonest
        case .openedNewest: return L10n.homeSortOpenedNewest
        case .openedOldest: return L10n.homeSortOpenedOldest
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var themeManager: ThemeManager

    @AppStorage("opelog.home.sort") private var sortRawValue: String = HomeSortOption.recentlyAdded.rawValue
    @AppStorage("opelog.home.category") private var categoryFilterRaw: String = ""
    @AppStorage("opelog.home.status") private var statusFilterRaw: String = ""

    @Query(
        filter: #Predicate<OpenItem> { !$0.isArchived }
    )
    private var unsortedActive: [OpenItem]

    @State private var presentedSheet: HomePresentedSheet?
    @State private var searchText: String = ""
    @State private var photoViewer: PhotoViewerPayload?

    private var homeSortOption: HomeSortOption {
        HomeSortOption(rawValue: sortRawValue) ?? .recentlyAdded
    }

    /// Empty string ⇒ all categories
    private var categoryFilterStored: String? {
        categoryFilterRaw.isEmpty ? nil : categoryFilterRaw
    }

    /// "" all, otherwise ItemStatus.rawValue
    private var statusFilter: ItemStatus? {
        guard !statusFilterRaw.isEmpty else { return nil }
        return ItemStatus(rawValue: statusFilterRaw)
    }

    private var displayItems: [OpenItem] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        var list = unsortedActive

        if !trimmedSearch.isEmpty {
            list = list.filter { $0.name.lowercased().contains(trimmedSearch) }
        }

        if let cat = categoryFilterStored {
            list = list.filter { $0.category == cat }
        }

        if let sf = statusFilter {
            list = list.filter { $0.status == sf }
        }

        switch homeSortOption {
        case .recentlyAdded:
            list.sort { $0.createdAt > $1.createdAt }
        case .checkSoonest:
            list.sort { $0.targetDate < $1.targetDate }
        case .openedNewest:
            list.sort { $0.openedDate > $1.openedDate }
        case .openedOldest:
            list.sort { $0.openedDate < $1.openedDate }
        }

        return list
    }

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                    if unsortedActive.isEmpty {
                        header
                    }

                    if displayItems.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(displayItems) { item in
                                NavigationLink {
                                    ItemDetailView(item: item)
                                } label: {
                                    ItemCardView(item: item, onPhotoTap: {
                                        photoViewer = PhotoViewerPayload(
                                            fileNames: item.resolvedImageFileNames,
                                            startIndex: 0
                                        )
                                    })
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .tint(themeManager.currentTheme.accentColor)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text(L10n.homeSearchPlaceholder))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Text(L10n.homeSortSection)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor)

                    ForEach(HomeSortOption.allCases) { opt in
                        Button {
                            sortRawValue = opt.rawValue
                        } label: {
                            HStack(spacing: 8) {
                                Text(opt.localizedTitle)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if opt.rawValue == sortRawValue {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(themeManager.currentTheme.accentColor)
                                }
                            }
                        }
                    }

                    Rectangle()
                        .fill(themeManager.currentTheme.subtleBorderColor.opacity(0.65))
                        .frame(height: 1)
                        .padding(.vertical, 4)

                    Menu(L10n.homeFilterCategorySection) {
                        Button(L10n.homeFilterCategoryAll) {
                            categoryFilterRaw = ""
                        }
                        ForEach(ItemCategory.allCases) { c in
                            Button(L10n.category(storedKey: c.rawValue)) {
                                categoryFilterRaw = c.rawValue
                            }
                        }
                    }

                    Menu(L10n.homeFilterStatusSection) {
                        Button(L10n.homeFilterStatusAll) {
                            statusFilterRaw = ""
                        }
                        Button(L10n.status(.good)) { statusFilterRaw = ItemStatus.good.rawValue }
                        Button(L10n.status(.soon)) { statusFilterRaw = ItemStatus.soon.rawValue }
                        Button(L10n.status(.expired)) { statusFilterRaw = ItemStatus.expired.rawValue }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.95))
                        .padding(.leading, 2)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presentAddFlow()
                } label: {
                    ZStack {
                        Circle()
                            .fill(themeManager.currentTheme.accentColor)
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.96))
                    }
                    .frame(width: 34, height: 34)
                    .shadow(color: Color.black.opacity(0.035), radius: 4, x: 0, y: 1.5)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.accessibilityAddItem)
            }
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .addItem:
                NavigationStack {
                    AddItemView(editingItem: nil)
                        .environmentObject(themeManager)
                }
            case .premium:
                PremiumView(emphasizesItemLimit: true)
                    .environmentObject(purchaseManager)
                    .environmentObject(themeManager)
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            OpelogBottomBannerInset()
        }
        .fullScreenCover(item: $photoViewer) { payload in
            PhotoViewerView(fileNames: payload.fileNames, startIndex: payload.startIndex)
        }
    }

    private func presentAddFlow() {
        if purchaseManager.canAddActiveItem(currentActiveCount: unsortedActive.count) {
            presentedSheet = .addItem
        } else {
            presentedSheet = .premium
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.appName)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(themeManager.currentTheme.primaryTextColor)

            VStack(alignment: .leading, spacing: 5) {
                Text(L10n.taglineHome)
                    .font(.body)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)

                Text(L10n.taglineSub)
                    .font(.subheadline)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(themeManager.currentTheme.accentColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                Image(systemName: "shippingbox")
                    .font(.system(size: 28, weight: .ultraLight))
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
            }

            VStack(spacing: 8) {
                Text(L10n.homeEmptyTitle)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text(L10n.homeEmptySubtitle)
                    .font(.subheadline)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 2)
            }

            Button {
                presentAddFlow()
            } label: {
                Text(L10n.actionAddItem)
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent)
            .tint(themeManager.currentTheme.accentColor)
            .padding(.horizontal, 8)
            .padding(.top, 2)
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .opelogCardChrome(cornerRadius: AppTheme.panelCorner)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: OpenItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return NavigationStack {
        HomeView()
            .environmentObject(PurchaseManager())
            .environmentObject(ThemeManager())
    }
    .modelContainer(container)
}
