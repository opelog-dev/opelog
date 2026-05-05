import SwiftUI

struct ThemePreviewCard: View {
    let theme: OpelogTheme
    let isSelected: Bool
    let isLocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ForEach(previewColors.indices, id: \.self) { index in
                    Circle()
                        .fill(previewColors[index])
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(theme.subtleBorderColor.opacity(0.8), lineWidth: 0.8)
                        )
                }
                Spacer()
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.secondaryTextColor)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.accentColor)
                }
            }

            Text(theme.localizedDisplayName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.primaryTextColor)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .multilineTextAlignment(.leading)

            if theme.isPremium {
                Text(L10n.premiumTheme)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(theme.secondaryTextColor)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.cardColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(theme.subtleBorderColor, lineWidth: isSelected ? 1.6 : 1)
        )
    }

    private var previewColors: [Color] {
        [theme.backgroundColor, theme.cardColor, theme.accentColor]
    }
}
