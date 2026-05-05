import SwiftData
import SwiftUI

struct ItemCardView: View {
    @Bindable var item: OpenItem
    @EnvironmentObject private var themeManager: ThemeManager
    /// When set and the item has stored photo file names, tapping the thumbnail opens the full-screen viewer (index 0).
    var onPhotoTap: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            OpelogPhotoThumbnailButton(
                displayFileName: item.primaryImageFileName,
                category: item.category,
                status: item.status,
                sideLength: AppTheme.cardThumbnailSize,
                cornerRadius: AppTheme.cardThumbnailCorner,
                neutralPlaceholder: false,
                resolvedFileNames: item.resolvedImageFileNames,
                onOpenViewer: onPhotoTap
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(themeManager.currentTheme.primaryTextColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.88)

                HStack(alignment: .center, spacing: 8) {
                    Text(L10n.category(storedKey: item.category))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)

                    Spacer(minLength: 4)

                    StatusBadgeView(status: item.status, style: .card)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(DateUtils.remainingDaysText(for: item))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.remainingAccent(for: item.status, theme: themeManager.currentTheme))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(DateUtils.openedDaysText(for: item))
                        .font(.caption)
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor.opacity(0.9))
                        .lineLimit(2)
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .opelogCardChrome(cornerRadius: AppTheme.cardCorner)
        .opelogPinnedCardAccent(category: item.category)
    }

    static func iconName(for category: String) -> String {
        switch ItemCategory.normalizedStorageKey(category) {
        case "Skincare": return "sparkles"
        case "Makeup": return "wand.and.stars"
        case "Haircare": return "comb.fill"
        case "Fragrance": return "drop.fill"
        case "Contact Lens": return "eye"
        case "Eye Drops": return "drop"
        case "Food": return "fork.knife"
        case "Pet Food": return "pawprint"
        case "Filters": return "line.3.horizontal.decrease.circle"
        case "Toothbrush": return "checkmark.circle"
        case "Razor": return "scissors"
        case "Medicine": return "cross.case"
        case "Supplements": return "pills"
        case "Daily Items": return "cabinet"
        case "Other": return "shippingbox"
        default: return "shippingbox"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: OpenItem.self, configurations: config)
    let item = OpenItem(name: "Serum", category: "Skincare", openedDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, recommendedDays: 90)
    container.mainContext.insert(item)
    return ItemCardView(item: item)
        .modelContainer(container)
        .environmentObject(ThemeManager())
        .padding()
        .background(OpelogTheme.freeDefault.backgroundColor)
}
