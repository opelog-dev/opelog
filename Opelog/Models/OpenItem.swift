import Foundation
import SwiftData

enum ItemStatus: String, Codable {
    case good
    case soon
    case expired
}

enum RepurchaseStatus: String, Codable, CaseIterable {
    case undecided
    case buyAgain
    case doNotBuyAgain
}

@Model
final class OpenItem {
    var name: String
    var category: String
    var openedDate: Date
    var recommendedDays: Int
    var memo: String
    /// Legacy single-photo field (kept for backward compatibility with existing records).
    var imageFileName: String?
    /// Multi-photo storage as newline-delimited file names (migration-safe for SwiftData).
    var imageFileNamesRawStorage: String?
    /// Free feature: personal favorite marker.
    var isFavoriteRaw: Bool?
    /// Stored as string for migration-safe persistence.
    var repurchaseStatusRaw: String?
    var repurchaseNoteRaw: String?
    var isArchived: Bool
    var finishedDate: Date?
    var notificationEnabled: Bool
    var createdAt: Date

    init(
        name: String,
        category: String = ItemCategory.skincare.rawValue,
        openedDate: Date = .now,
        recommendedDays: Int = 90,
        memo: String = "",
        imageFileName: String? = nil,
        imageFileNames: [String] = [],
        isFavorite: Bool = false,
        repurchaseStatus: RepurchaseStatus = .undecided,
        repurchaseNote: String = "",
        isArchived: Bool = false,
        finishedDate: Date? = nil,
        notificationEnabled: Bool = true,
        createdAt: Date = .now
    ) {
        self.name = name
        self.category = category
        self.openedDate = openedDate
        self.recommendedDays = recommendedDays
        self.memo = memo
        let normalizedIncoming = imageFileNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let resolvedNames: [String]
        let resolvedPrimary: String?
        if normalizedIncoming.isEmpty, let legacy = imageFileName?.trimmingCharacters(in: .whitespacesAndNewlines), !legacy.isEmpty {
            resolvedNames = [legacy]
            resolvedPrimary = legacy
        } else {
            let deduped = Array(NSOrderedSet(array: normalizedIncoming)) as? [String] ?? normalizedIncoming
            resolvedNames = deduped
            resolvedPrimary = deduped.first
        }
        self.imageFileNamesRawStorage = resolvedNames.joined(separator: "\n")
        self.imageFileName = resolvedPrimary
        self.isFavoriteRaw = isFavorite
        self.repurchaseStatusRaw = repurchaseStatus.rawValue
        self.repurchaseNoteRaw = repurchaseNote
        self.isArchived = isArchived
        self.finishedDate = finishedDate
        self.notificationEnabled = notificationEnabled
        self.createdAt = createdAt
    }

    var daysSinceOpened: Int {
        DateUtils.fullCalendarDaysSinceOpened(from: openedDate, to: Date())
    }

    var remainingDays: Int {
        recommendedDays - daysSinceOpened
    }

    var targetDate: Date {
        DateUtils.calendar.date(byAdding: .day, value: recommendedDays, to: DateUtils.startOfDay(openedDate)) ?? openedDate
    }

    var status: ItemStatus {
        let remaining = remainingDays
        if remaining < 0 { return .expired }
        if remaining <= 7 { return .soon }
        return .good
    }

    /// Returns all usable photo file names. Existing single-photo records are preserved.
    var resolvedImageFileNames: [String] {
        var merged = (imageFileNamesRawStorage ?? "")
            .split(separator: "\n")
            .map(String.init)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if let legacy = imageFileName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !legacy.isEmpty,
           !merged.contains(legacy) {
            merged.insert(legacy, at: 0)
        }
        return merged
    }

    var primaryImageFileName: String? {
        resolvedImageFileNames.first
    }

    func setResolvedImageFileNames(_ names: [String]) {
        let normalized = names
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let deduped = Array(NSOrderedSet(array: normalized)) as? [String] ?? normalized
        imageFileNamesRawStorage = deduped.isEmpty ? nil : deduped.joined(separator: "\n")
        imageFileName = deduped.first
    }

    var isFavorite: Bool {
        get { isFavoriteRaw ?? false }
        set { isFavoriteRaw = newValue }
    }

    var repurchaseStatus: RepurchaseStatus {
        get { RepurchaseStatus(rawValue: repurchaseStatusRaw ?? "") ?? .undecided }
        set { repurchaseStatusRaw = newValue.rawValue }
    }

    var repurchaseNote: String {
        get { repurchaseNoteRaw ?? "" }
        set { repurchaseNoteRaw = newValue }
    }
}
