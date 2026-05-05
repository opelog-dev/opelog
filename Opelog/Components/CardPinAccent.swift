import SwiftUI

// MARK: - Category palette (fixed sRGB from design hex — vivid but not neon)

private enum CardPinPalette {
    /// sRGB 0…1 from `#RRGGBB` (category → consistent pin head).
    private static func headRGB(forStoredCategory raw: String) -> (Double, Double, Double) {
        switch ItemCategory.normalizedStorageKey(raw) {
        case "Skincare": return rgb(0xE5, 0x7C, 0x9C) // pink
        case "Makeup": return rgb(0xE9, 0x4E, 0x8A) // rose / magenta pink
        case "Haircare": return rgb(0x8C, 0x7C, 0xF0) // violet
        case "Fragrance": return rgb(0xA9, 0x6B, 0xE0) // purple
        case "Contact Lens": return rgb(0x4F, 0x9D, 0xE8) // blue
        case "Eye Drops": return rgb(0x55, 0xA4, 0xEA) // blue (distinct from contact)
        case "Medicine": return rgb(0x63, 0xB6, 0x6D) // green
        case "Supplements": return rgb(0x54, 0xBE, 0x6F) // green variant
        case "Food": return rgb(0xF2, 0xA5, 0x41) // orange
        case "Pet Food": return rgb(0xC9, 0x8A, 0x5B) // warm brown
        case "Filters": return rgb(0x5C, 0x7C, 0xFA) // indigo / blue
        case "Toothbrush": return rgb(0x3F, 0xA7, 0xD6) // blue
        case "Razor": return rgb(0x6C, 0x8A, 0xE4) // cool blue-violet
        case "Daily Items": return rgb(0xB2, 0x87, 0x5A) // brown
        case "Other": return rgb(0x8E, 0x8E, 0x93) // gray
        default: return rgb(0x8E, 0x8E, 0x93)
        }
    }

    private static func rgb(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> (Double, Double, Double) {
        (Double(r) / 255.0, Double(g) / 255.0, Double(b) / 255.0)
    }

    static func headColor(forStoredCategory raw: String) -> Color {
        let (r, g, b) = headRGB(forStoredCategory: raw)
        return Color(red: r, green: g, blue: b)
    }

    /// Darker stem so it reads on soft card chrome.
    static func stemColor(forStoredCategory raw: String) -> Color {
        let (r, g, b) = headRGB(forStoredCategory: raw)
        return Color(red: r * 0.66, green: g * 0.66, blue: b * 0.66)
    }

    /// Outline: darker than head for separation from the card.
    static func strokeColor(forStoredCategory raw: String) -> Color {
        let (r, g, b) = headRGB(forStoredCategory: raw)
        return Color(red: r * 0.48, green: g * 0.48, blue: b * 0.48, opacity: 0.98)
    }
}

// MARK: - Pin view

/// Top-center “push pin” for list cards — category-colored, vivid but not harsh.
struct CardPinAccent: View {
    let category: String

    private let headDiameter: CGFloat = 11
    private let stemWidth: CGFloat = 2.55
    private let stemHeight: CGFloat = 4.25

    private var head: Color { CardPinPalette.headColor(forStoredCategory: category) }
    private var stem: Color { CardPinPalette.stemColor(forStoredCategory: category) }
    private var stroke: Color { CardPinPalette.strokeColor(forStoredCategory: category) }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                head.opacity(0.98),
                                head,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: headDiameter, height: headDiameter)
                Circle()
                    .strokeBorder(stroke, lineWidth: 0.85)
                    .frame(width: headDiameter, height: headDiameter)
            }
            RoundedRectangle(cornerRadius: 0.9, style: .continuous)
                .fill(stem)
                .frame(width: stemWidth, height: stemHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 0.9, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.12), lineWidth: 0.35)
                )
        }
        .shadow(color: Color.black.opacity(0.18), radius: 4.2, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.09), radius: 1.8, x: 0, y: 0.6)
        .accessibilityHidden(true)
    }
}

extension View {
    /// Small decorative pin at top center, slightly overlapping the card’s top edge.
    func opelogPinnedCardAccent(category: String, offsetY: CGFloat = -5) -> some View {
        overlay(alignment: .top) {
            CardPinAccent(category: category)
                .offset(y: offsetY)
                .allowsHitTesting(false)
        }
    }
}
