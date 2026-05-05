import SwiftData
import SwiftUI

struct ItemDetailView: View {
    @Bindable var item: OpenItem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var showDeleteConfirm = false
    @State private var showMarkFinishedConfirm = false
    @State private var photoViewer: PhotoViewerPayload?

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    statusHero

                    detailPanel

                    repurchasePanel

                    if !item.memo.isEmpty {
                        memoBlock
                    }

                    if !item.isArchived {
                        Button {
                            showMarkFinishedConfirm = true
                        } label: {
                            Text(L10n.actionMarkFinished)
                                .font(.headline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(themeManager.currentTheme.accentColor)
                    }

                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Text(L10n.actionDeleteItem)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .tint(themeManager.currentTheme.accentColor)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    AddItemView(editingItem: item)
                } label: {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 17, weight: .medium))
                }
                .accessibilityLabel(L10n.actionEditItem)
            }
        }
        .alert(L10n.alertDeleteTitle, isPresented: $showDeleteConfirm) {
            Button(L10n.actionCancel, role: .cancel) {}
            Button(L10n.actionDelete, role: .destructive) { deleteItem() }
        } message: {
            Text(L10n.alertDeleteMessage)
        }
        .alert(L10n.alertMarkFinishedTitle, isPresented: $showMarkFinishedConfirm) {
            Button(L10n.actionCancel, role: .cancel) {}
            Button(L10n.actionMarkFinished) { markFinished() }
        } message: {
            Text(L10n.alertMarkFinishedMessage)
        }
        .fullScreenCover(item: $photoViewer) { payload in
            PhotoViewerView(fileNames: payload.fileNames, startIndex: payload.startIndex)
        }
    }

    private var statusHero: some View {
        VStack(spacing: 14) {
            OpelogPhotoThumbnailButton(
                displayFileName: item.primaryImageFileName,
                category: item.category,
                status: item.status,
                sideLength: AppTheme.detailHeroThumbSize,
                cornerRadius: AppTheme.detailHeroThumbCorner,
                neutralPlaceholder: false,
                resolvedFileNames: item.resolvedImageFileNames,
                onOpenViewer: {
                    photoViewer = PhotoViewerPayload(
                        fileNames: item.resolvedImageFileNames,
                        startIndex: 0
                    )
                }
            )

            if item.resolvedImageFileNames.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(item.resolvedImageFileNames.enumerated()), id: \.offset) { index, fileName in
                            OpelogPhotoThumbnailButton(
                                displayFileName: fileName,
                                category: item.category,
                                status: item.status,
                                sideLength: 58,
                                cornerRadius: 16,
                                neutralPlaceholder: false,
                                resolvedFileNames: item.resolvedImageFileNames,
                                onOpenViewer: {
                                    photoViewer = PhotoViewerPayload(
                                        fileNames: item.resolvedImageFileNames,
                                        startIndex: index
                                    )
                                }
                            )
                        }
                    }
                }
            }

            if item.isArchived {
                Text(L10n.finishedStatus)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(themeManager.currentTheme.secondaryAccentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(themeManager.currentTheme.cardColor)
                    )
                    .overlay(
                        Capsule()
                            .stroke(themeManager.currentTheme.subtleBorderColor.opacity(0.8), lineWidth: 1)
                    )
            } else {
                StatusBadgeView(status: item.status, style: .hero)
            }

            VStack(spacing: 8) {
                Text(item.isArchived ? L10n.usedForDays(usageDays) : DateUtils.openedDaysText(for: item))
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text(item.isArchived ? finishedPeriodText : DateUtils.remainingDaysText(for: item))
                    .font(.body.weight(.medium))
                    .foregroundStyle(item.isArchived ? themeManager.currentTheme.secondaryTextColor : AppTheme.remainingAccent(for: item.status, theme: themeManager.currentTheme))
                    .multilineTextAlignment(.center)
            }

            if !item.isArchived && item.status == .expired {
                Text(L10n.detailHintPastEstimate)
                    .font(.footnote)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 10)
            } else if !item.isArchived && item.status == .soon {
                Text(L10n.detailHintReplaceSoon)
                    .font(.footnote)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 22)
        .opelogCardChrome(cornerRadius: AppTheme.heroCorner)
    }

    private var detailPanel: some View {
        VStack(spacing: 0) {
            detailField(title: L10n.detailRowCategory, value: L10n.category(storedKey: item.category))
            softDivider
            detailField(title: L10n.detailRowOpenedDate, value: DateUtils.formattedDate(item.openedDate))
            softDivider
            if item.isArchived {
                detailField(title: L10n.detailRowFinishedDate, value: DateUtils.formattedDate(item.finishedDate ?? item.openedDate))
                softDivider
                detailField(title: L10n.detailRowUsageDays, value: L10n.usedForDays(usageDays))
                softDivider
                detailField(title: L10n.detailRowCheckEstimate, value: DateUtils.formattedDate(item.targetDate))
            } else {
                detailField(title: L10n.detailRowTargetDate, value: DateUtils.formattedDate(item.targetDate))
                softDivider
                detailField(title: L10n.detailRowDaysSinceOpened, value: "\(item.daysSinceOpened)")
                softDivider
                detailField(title: L10n.detailRowRemainingEstimate, value: DateUtils.remainingDaysText(for: item))
            }
            softDivider
            detailField(
                title: L10n.detailRowNotifications,
                value: item.notificationEnabled ? L10n.detailNotificationOn : L10n.detailNotificationOff
            )
        }
        .padding(.vertical, 4)
        .opelogCardChrome(cornerRadius: AppTheme.panelCorner)
    }

    private var memoBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.detailMemoHeader)
                .font(.caption.weight(.semibold))
                .foregroundStyle(themeManager.currentTheme.secondaryTextColor)

            Text(item.memo)
                .font(.body)
                .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opelogCardChrome(cornerRadius: AppTheme.panelCorner)
    }

    private var repurchasePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            if item.isArchived {
                Text(L10n.howWasThisItem)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(themeManager.currentTheme.primaryTextColor)
            }

            Toggle(isOn: $item.isFavorite) {
                Text(item.isFavorite ? L10n.actionRemoveFavorite : L10n.actionMarkFavorite)
                    .font(.subheadline.weight(.semibold))
            }
            .tint(themeManager.currentTheme.accentColor)

            if item.isArchived {
                Picker(L10n.detailRepurchaseStatus, selection: Binding(
                    get: { item.repurchaseStatus },
                    set: { item.repurchaseStatus = $0 }
                )) {
                    ForEach(RepurchaseStatus.allCases, id: \.rawValue) { status in
                        Text(L10n.repurchaseStatus(status)).tag(status)
                    }
                }
                .pickerStyle(.menu)

                TextField("", text: $item.repurchaseNote, prompt: Text(L10n.detailRepurchaseNote), axis: .vertical)
                    .lineLimit(2...6)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opelogCardChrome(cornerRadius: AppTheme.panelCorner)
    }

    private var softDivider: some View {
        Rectangle()
            .fill(themeManager.currentTheme.subtleBorderColor)
            .frame(height: 1)
            .padding(.leading, 18)
    }

    private func detailField(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.95))
            Text(value)
                .font(.body)
                .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    private func markFinished() {
        item.isArchived = true
        item.finishedDate = Date()
        NotificationService.cancelReminder(for: item)
        try? modelContext.save()
        dismiss()
    }

    private var usageDays: Int {
        DateUtils.usageDays(openedDate: item.openedDate, finishedDate: item.finishedDate)
    }

    private var finishedPeriodText: String {
        let opened = DateUtils.archiveScanDate(item.openedDate)
        let finished = DateUtils.archiveScanDate(item.finishedDate ?? item.openedDate)
        return L10n.finishedPeriod(opened: opened, finished: finished)
    }

    private func deleteItem() {
        NotificationService.cancelReminder(for: item)
        for fileName in item.resolvedImageFileNames {
            ImageStorageService.deleteImage(fileName: fileName)
        }
        modelContext.delete(item)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: OpenItem.self, configurations: config)
    let item = OpenItem(name: "Cream", category: "Skincare", openedDate: Date(), recommendedDays: 90)
    container.mainContext.insert(item)
    return NavigationStack {
        ItemDetailView(item: item)
    }
    .environmentObject(PurchaseManager())
    .environmentObject(ThemeManager())
    .modelContainer(container)
}
