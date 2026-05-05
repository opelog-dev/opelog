import PhotosUI
import SwiftData
import SwiftUI
import UIKit

private enum DayPreset: CaseIterable, Identifiable {
    case thirty, sixty, ninety, oneEighty, threeSixtyFive, custom

    var id: Self { self }

    var days: Int? {
        switch self {
        case .thirty: return 30
        case .sixty: return 60
        case .ninety: return 90
        case .oneEighty: return 180
        case .threeSixtyFive: return 365
        case .custom: return nil
        }
    }

    var localizedTitle: String {
        switch self {
        case .thirty: return L10n.dayPreset30
        case .sixty: return L10n.dayPreset60
        case .ninety: return L10n.dayPreset90
        case .oneEighty: return L10n.dayPreset180
        case .threeSixtyFive: return L10n.dayPreset365
        case .custom: return L10n.dayPresetCustom
        }
    }

    static func matching(days: Int) -> DayPreset? {
        switch days {
        case 30: return .thirty
        case 60: return .sixty
        case 90: return .ninety
        case 180: return .oneEighty
        case 365: return .threeSixtyFive
        default: return nil
        }
    }
}

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var purchaseManager: PurchaseManager

    /// Non-`nil` when editing an existing item (same persistence record; never inserts a duplicate).
    var editingItem: OpenItem?

    @State private var name: String = ""
    @State private var category: String = ItemCategory.skincare.rawValue
    @State private var openedDate: Date = .now
    @State private var dayPreset: DayPreset = .ninety
    @State private var customDays: String = "90"
    @State private var notificationEnabled: Bool = true
    @State private var memo: String = ""

    @State private var photoPickerItem: PhotosPickerItem?
    @State private var draftPhotos: [DraftPhotoEntry] = []
    @State private var showLibraryPicker = false
    @State private var showCameraSheet = false
    @State private var cameraImage: UIImage?
    @State private var showPremiumSheet = false
    @State private var showPhotoLimitAlert = false
    @State private var showSaveErrorAlert = false
    @State private var saveErrorDetail = ""
    @State private var hydratedFromEditing = false

    private struct DraftPhotoEntry: Identifiable {
        let id = UUID()
        var existingFileName: String?
        var data: Data?
    }

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var resolvedRecommendedDays: Int {
        if let d = dayPreset.days { return max(1, d) }
        let n = Int(customDays.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 1
        return max(1, n)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty
    }

    private var isEditing: Bool { editingItem != nil }
    private var maxPhotoCount: Int {
        purchaseManager.isPremium ? 5 : 1
    }

    var body: some View {
        Form {
            Section {
                ZStack(alignment: .leading) {
                    TextField("", text: $name)
                        .textFieldStyle(.plain)
                        .accessibilityLabel(L10n.fieldItemName)
                        .textInputAutocapitalization(.sentences)
                        .font(.body.weight(.medium))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: max(22, UIFont.preferredFont(forTextStyle: .body).lineHeight),
                            alignment: .leading
                        )

                    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(L10n.fieldItemName)
                            .font(.body.weight(.medium))
                            .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.42))
                            .allowsHitTesting(false)
                    }
                }

                Picker(L10n.fieldCategory, selection: $category) {
                    ForEach(ItemCategory.allCases) { c in
                        Text(L10n.category(storedKey: c.rawValue)).tag(c.rawValue)
                    }
                }

                DatePicker(L10n.fieldOpenedDate, selection: $openedDate, displayedComponents: .date)
            }

            Section {
                Menu {
                    if cameraAvailable {
                        Button {
                            attemptOpenCamera()
                        } label: {
                            Label(L10n.actionTakePhoto, systemImage: "camera")
                        }
                    }
                    Button {
                        attemptOpenLibrary()
                    } label: {
                        Label(L10n.actionChooseFromLibrary, systemImage: "photo.on.rectangle")
                    }
                } label: {
                    Label(L10n.actionAddPhoto, systemImage: "photo.badge.plus")
                        .foregroundStyle(themeManager.currentTheme.accentColor)
                }
                .buttonStyle(.plain)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(draftPhotos.enumerated()), id: \.element.id) { index, entry in
                            photoCell(for: entry, at: index)
                        }

                        addPhotoTile
                    }
                    .padding(.vertical, 2)
                }

                if !purchaseManager.isPremium, draftPhotos.count >= 1 {
                    Button {
                        showPremiumSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.caption.weight(.semibold))
                            Text(L10n.addMorePhotosWithPremium)
                                .font(.footnote.weight(.semibold))
                        }
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(themeManager.currentTheme.cardColor)
                        )
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text(L10n.fieldPhoto)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .textCase(nil)
            } footer: {
                Text(L10n.footerPhotoLocal)
                    .font(.caption)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.9))
                    .lineSpacing(2)
            }

            Section {
                Picker(L10n.fieldUseWithin, selection: $dayPreset) {
                    ForEach(DayPreset.allCases) { preset in
                        Text(preset.localizedTitle).tag(preset)
                    }
                }
                .pickerStyle(.menu)

                if dayPreset == .custom {
                    TextField("", text: $customDays, prompt: Text(L10n.fieldDays))
                        .keyboardType(.numberPad)
                        .font(.body.monospacedDigit())
                }
            } footer: {
                Text(L10n.footerUseWithinExplanation)
                    .font(.caption)
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.9))
                    .lineSpacing(2)
            }

            Section {
                Toggle(isOn: $notificationEnabled) {
                    Text(L10n.fieldNotification)
                        .foregroundStyle(themeManager.currentTheme.primaryTextColor.opacity(0.9))
                }
                .tint(themeManager.currentTheme.accentColor)
            } footer: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.footerNotificationsMvp)
                        .font(.caption)
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.9))
                        .lineSpacing(2)
                    Text(L10n.footerNotificationsPermissionHint)
                        .font(.caption)
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.88))
                        .lineSpacing(2)
                }
            }

            Section {
                TextField("", text: $memo, prompt: Text(L10n.fieldOptionalNotes), axis: .vertical)
                    .lineLimit(3...8)
            } header: {
                Text(L10n.fieldMemo)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                    .textCase(nil)
            }

            if isEditing {
                Section {
                    Toggle(isOn: Binding(
                        get: { editingItem?.isFavorite ?? false },
                        set: { editingItem?.isFavorite = $0 }
                    )) {
                        Text(L10n.detailFavoriteToggle)
                    }
                    .tint(themeManager.currentTheme.accentColor)

                    Picker(L10n.detailRepurchaseStatus, selection: Binding(
                        get: { editingItem?.repurchaseStatus ?? .undecided },
                        set: { editingItem?.repurchaseStatus = $0 }
                    )) {
                        ForEach(RepurchaseStatus.allCases, id: \.rawValue) { status in
                            Text(L10n.repurchaseStatus(status)).tag(status)
                        }
                    }

                    TextField("", text: Binding(
                        get: { editingItem?.repurchaseNote ?? "" },
                        set: { editingItem?.repurchaseNote = $0 }
                    ), prompt: Text(L10n.detailRepurchaseNote), axis: .vertical)
                    .lineLimit(2...5)
                } header: {
                    Text(L10n.afterUseSection)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        .textCase(nil)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.currentTheme.backgroundColor)
        .listRowBackground(themeManager.currentTheme.cardColor)
        .listSectionSpacing(26)
        .navigationTitle(isEditing ? L10n.actionEditItem : L10n.actionAddItem)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n.actionCancel) { dismiss() }
                    .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.actionSave) { save() }
                    .disabled(!canSave)
                    .font(.body.weight(canSave ? .bold : .medium))
                    .foregroundStyle(
                        canSave
                            ? AnyShapeStyle(themeManager.currentTheme.accentColor)
                            : AnyShapeStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.38))
                    )
            }
        }
        .tint(themeManager.currentTheme.accentColor)
        .photosPicker(isPresented: $showLibraryPicker, selection: $photoPickerItem, matching: .images, photoLibrary: .shared())
        .fullScreenCover(isPresented: $showCameraSheet) {
            CameraImagePicker(isPresented: $showCameraSheet, image: $cameraImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumView(emphasizesItemLimit: false)
                .environmentObject(purchaseManager)
                .environmentObject(themeManager)
        }
        .alert(L10n.multiplePhotoLimitTitle, isPresented: $showPhotoLimitAlert) {
            Button(L10n.actionOK) {}
        } message: {
            Text(L10n.multiplePhotoPremiumMaxMessage)
        }
        .alert(L10n.saveFailedTitle, isPresented: $showSaveErrorAlert) {
            Button(L10n.actionOK) {}
        } message: {
            Text(saveErrorDetail.isEmpty ? L10n.saveFailedMessage : saveErrorDetail)
        }
        .onAppear {
            guard let item = editingItem, !hydratedFromEditing else { return }
            hydratedFromEditing = true
            hydrate(from: item)
        }
        .onChange(of: photoPickerItem) { _, newValue in
            Task { await appendPhoto(from: newValue) }
        }
        .onChange(of: cameraImage) { _, newValue in
            guard let newValue else { return }
            if let data = newValue.jpegData(compressionQuality: 0.92) {
                appendPhotoData(data)
            }
            photoPickerItem = nil
            cameraImage = nil
        }
    }

    private func photoCell(for entry: DraftPhotoEntry, at index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let fileName = entry.existingFileName,
                   let ui = ImageStorageService.loadUIImage(fileName: fileName) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                } else if let data = entry.data, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(themeManager.currentTheme.secondaryTextColor.opacity(0.12))
                    Image(systemName: "photo")
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.85))
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(themeManager.currentTheme.subtleBorderColor.opacity(0.75), lineWidth: 1)
            )

            Button {
                draftPhotos.remove(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white, themeManager.currentTheme.accentColor)
                    .background(Circle().fill(themeManager.currentTheme.backgroundColor))
            }
            .offset(x: 6, y: -6)
        }
    }

    private var addPhotoTile: some View {
        Menu {
            if cameraAvailable {
                Button {
                    attemptOpenCamera()
                } label: {
                    Label(L10n.actionTakePhoto, systemImage: "camera")
                }
            }
            Button {
                attemptOpenLibrary()
            } label: {
                Label(L10n.actionChooseFromLibrary, systemImage: "photo.on.rectangle")
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                Text(L10n.addMorePhotos)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(themeManager.currentTheme.accentColor)
            .frame(width: 72, height: 72)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(themeManager.currentTheme.cardColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(themeManager.currentTheme.subtleBorderColor.opacity(0.85), lineWidth: 1)
            )
            .opacity(draftPhotos.count < maxPhotoCount ? 1 : 0.55)
        }
        .buttonStyle(.plain)
    }

    private func attemptOpenCamera() {
        guard cameraAvailable else { return }
        guard ensurePhotoCapacityAvailable() else { return }
        showCameraSheet = true
    }

    private func attemptOpenLibrary() {
        guard ensurePhotoCapacityAvailable() else { return }
        photoPickerItem = nil
        showLibraryPicker = true
    }

    private func ensurePhotoCapacityAvailable() -> Bool {
        if draftPhotos.count >= maxPhotoCount {
            if purchaseManager.isPremium {
                showPhotoLimitAlert = true
            } else {
                showPremiumSheet = true
            }
            return false
        }
        return true
    }

    private func hydrate(from item: OpenItem) {
        name = item.name
        let normalizedCategory = ItemCategory.normalizedStorageKey(item.category)
        category = ItemCategory.allCases.contains(where: { $0.rawValue == normalizedCategory })
            ? normalizedCategory
            : ItemCategory.other.rawValue
        openedDate = item.openedDate
        let rd = max(1, item.recommendedDays)
        if let preset = DayPreset.matching(days: rd) {
            dayPreset = preset
            customDays = "\(rd)"
        } else {
            dayPreset = .custom
            customDays = "\(rd)"
        }
        notificationEnabled = item.notificationEnabled
        memo = item.memo
        draftPhotos = item.resolvedImageFileNames.map { DraftPhotoEntry(existingFileName: $0, data: nil) }
    }

    private func appendPhoto(from item: PhotosPickerItem?) async {
        guard let item else {
            return
        }
        if let data = try? await item.loadTransferable(type: Data.self) {
            await MainActor.run { appendPhotoData(data) }
        }
    }

    private func appendPhotoData(_ data: Data) {
        guard draftPhotos.count < maxPhotoCount else {
            if purchaseManager.isPremium {
                showPhotoLimitAlert = true
            } else {
                showPremiumSheet = true
            }
            return
        }
        draftPhotos.append(DraftPhotoEntry(existingFileName: nil, data: data))
    }

    private func save() {
        let finalFileNames = persistDraftPhotos()
        let normalized = ItemCategory.normalizedStorageKey(category)
        let storedCategory = ItemCategory.allCases.contains(where: { $0.rawValue == normalized })
            ? normalized
            : ItemCategory.other.rawValue

        if let editing = editingItem {
            let oldFileNames = editing.resolvedImageFileNames
            let removed = Set(oldFileNames).subtracting(finalFileNames)
            for fileName in removed {
                ImageStorageService.deleteImage(fileName: fileName)
            }
            editing.setResolvedImageFileNames(finalFileNames)

            editing.name = trimmedName
            editing.category = storedCategory
            editing.openedDate = openedDate
            editing.recommendedDays = resolvedRecommendedDays
            editing.memo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
            editing.notificationEnabled = notificationEnabled

            do {
                try modelContext.save()
            } catch {
                saveErrorDetail = error.localizedDescription
                showSaveErrorAlert = true
                return
            }
            NotificationService.refreshReminder(for: editing)
            dismiss()
            return
        }

        let item = OpenItem(
            name: trimmedName,
            category: storedCategory,
            openedDate: openedDate,
            recommendedDays: resolvedRecommendedDays,
            memo: memo.trimmingCharacters(in: .whitespacesAndNewlines),
            imageFileName: finalFileNames.first,
            imageFileNames: finalFileNames,
            notificationEnabled: notificationEnabled
        )
        modelContext.insert(item)
        do {
            try modelContext.save()
        } catch {
            modelContext.delete(item)
            saveErrorDetail = error.localizedDescription
            showSaveErrorAlert = true
            return
        }
        NotificationService.refreshReminder(for: item)
        dismiss()
    }

    private func persistDraftPhotos() -> [String] {
        var names: [String] = []
        for photo in draftPhotos {
            if let existing = photo.existingFileName {
                names.append(existing)
            } else if let data = photo.data,
                      let saved = try? ImageStorageService.saveImage(data: data) {
                names.append(saved)
            }
        }
        return names
    }
}

#Preview("Add") {
    let container = try! ModelContainer(
        for: OpenItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return NavigationStack {
        AddItemView(editingItem: nil)
            .environmentObject(PurchaseManager())
            .environmentObject(ThemeManager())
    }
    .modelContainer(container)
}

#Preview("Edit") {
    let container = try! ModelContainer(
        for: OpenItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let existing = OpenItem(name: "Serum", category: "Skincare", openedDate: Date(), recommendedDays: 45)
    container.mainContext.insert(existing)
    return NavigationStack {
        AddItemView(editingItem: existing)
            .environmentObject(PurchaseManager())
            .environmentObject(ThemeManager())
    }
    .modelContainer(container)
}
