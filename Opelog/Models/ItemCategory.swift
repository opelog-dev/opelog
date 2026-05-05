import Foundation

/// Stored `OpenItem.category` values (English keys). Display names use `L10n.category(storedKey:)`.
enum ItemCategory: String, CaseIterable, Identifiable {
    case skincare = "Skincare"
    case makeup = "Makeup"
    case haircare = "Haircare"
    case fragrance = "Fragrance"
    case contactLens = "Contact Lens"
    case eyeDrops = "Eye Drops"
    case food = "Food"
    case petFood = "Pet Food"
    case filters = "Filters"
    case toothbrush = "Toothbrush"
    case razor = "Razor"
    case medicine = "Medicine"
    case supplements = "Supplements"
    case dailyItems = "Daily Items"
    case other = "Other"

    var id: String { rawValue }

    /// Maps legacy stored labels to the current English storage key (icons + localization tables).
    static func normalizedStorageKey(_ raw: String) -> String {
        switch raw {
        case ItemCategory.skincare.rawValue, "スキンケア": return ItemCategory.skincare.rawValue
        case ItemCategory.makeup.rawValue, "コスメ": return ItemCategory.makeup.rawValue
        case ItemCategory.haircare.rawValue, "ヘアケア": return ItemCategory.haircare.rawValue
        case ItemCategory.fragrance.rawValue, "香水": return ItemCategory.fragrance.rawValue
        case ItemCategory.contactLens.rawValue, "コンタクト", "コンタクトレンズ": return ItemCategory.contactLens.rawValue
        case ItemCategory.eyeDrops.rawValue, "目薬": return ItemCategory.eyeDrops.rawValue
        case ItemCategory.food.rawValue, "食品": return ItemCategory.food.rawValue
        case ItemCategory.petFood.rawValue, "ペットフード": return ItemCategory.petFood.rawValue
        case ItemCategory.filters.rawValue, "フィルター": return ItemCategory.filters.rawValue
        case ItemCategory.toothbrush.rawValue, "歯ブラシ": return ItemCategory.toothbrush.rawValue
        case ItemCategory.razor.rawValue, "カミソリ": return ItemCategory.razor.rawValue
        case ItemCategory.medicine.rawValue, "薬": return ItemCategory.medicine.rawValue
        case ItemCategory.supplements.rawValue, "サプリ": return ItemCategory.supplements.rawValue
        case ItemCategory.dailyItems.rawValue, "日用品": return ItemCategory.dailyItems.rawValue
        case ItemCategory.other.rawValue, "その他": return ItemCategory.other.rawValue
        default: return raw
        }
    }
}
