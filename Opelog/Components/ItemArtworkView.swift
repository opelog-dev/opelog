import SwiftUI
import UIKit

/// Rounded-square artwork: saved photo (`aspectFill`) or soft placeholder + category symbol.
struct ItemArtworkView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let imageFileName: String?
    let category: String
    var status: ItemStatus = .good
    var sideLength: CGFloat = AppTheme.cardThumbnailSize
    var cornerRadius: CGFloat = AppTheme.cardThumbnailCorner
    var neutralPlaceholder: Bool = false

    private var thumbShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    private var symbolPointSize: CGFloat {
        max(14, sideLength * 0.34)
    }

    var body: some View {
        Group {
            if let name = imageFileName, let ui = ImageStorageService.loadUIImage(fileName: name) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: sideLength, height: sideLength)
                    .clipShape(thumbShape)
                    .overlay(
                        thumbShape.strokeBorder(themeManager.currentTheme.subtleBorderColor.opacity(0.6), lineWidth: 0.5)
                    )
            } else {
                ZStack {
                    thumbShape
                        .fill(AppTheme.placeholderOrbFill(status: status, neutral: neutralPlaceholder, theme: themeManager.currentTheme))
                    Image(systemName: ItemCardView.iconName(for: category))
                        .font(.system(size: symbolPointSize, weight: .regular))
                        .foregroundStyle(themeManager.currentTheme.secondaryTextColor)
                }
                .frame(width: sideLength, height: sideLength)
                .clipShape(thumbShape)
                .overlay(
                    thumbShape.strokeBorder(themeManager.currentTheme.subtleBorderColor.opacity(0.55), lineWidth: 0.5)
                )
            }
        }
        .frame(width: sideLength, height: sideLength)
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 16) {
        ItemArtworkView(imageFileName: nil, category: "Skincare", status: .good)
        ItemArtworkView(imageFileName: nil, category: "Makeup", status: .soon, neutralPlaceholder: true)
        ItemArtworkView(
            imageFileName: nil,
            category: "Food",
            status: .good,
            sideLength: AppTheme.detailHeroThumbSize,
            cornerRadius: AppTheme.detailHeroThumbCorner
        )
    }
    .environmentObject(ThemeManager())
    .padding()
    .background(OpelogTheme.freeDefault.backgroundColor)
}
