import SwiftUI
import UIKit

/// Identifies a full-screen photo presentation (new `id` each time the viewer opens).
struct PhotoViewerPayload: Identifiable {
    let id = UUID()
    let fileNames: [String]
    let startIndex: Int
}

// MARK: - Full-screen viewer

struct PhotoViewerView: View {
    let fileNames: [String]
    let startIndex: Int
    @Environment(\.dismiss) private var dismiss

    @State private var selection: Int

    init(fileNames: [String], startIndex: Int) {
        self.fileNames = fileNames
        let upper = max(fileNames.count - 1, 0)
        let clamped = min(max(0, startIndex), upper)
        self.startIndex = clamped
        _selection = State(initialValue: clamped)
    }

    private var currentPage: Int {
        min(max(0, selection), max(fileNames.count - 1, 0))
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if fileNames.isEmpty {
                Text(L10n.photoLoadFailed)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                TabView(selection: $selection) {
                    ForEach(Array(fileNames.enumerated()), id: \.offset) { index, fileName in
                        PhotoViewerPageView(fileName: fileName)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text(L10n.photoViewerClose)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .accessibilityLabel(L10n.photoViewerClose)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                if fileNames.count > 1 {
                    Text(L10n.photoPage(current: currentPage + 1, total: fileNames.count))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.12), in: Capsule())
                        .padding(.bottom, 20)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Single page (load + zoom)

private struct PhotoViewerPageView: View {
    let fileName: String

    var body: some View {
        Group {
            if let ui = ImageStorageService.loadUIImage(fileName: fileName) {
                PinchZoomPhotoPage(uiImage: ui)
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "photo")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(.white.opacity(0.55))
                    Text(L10n.photoLoadFailed)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
            }
        }
    }
}

/// Pinch to zoom, drag to pan when zoomed, double-tap to reset.
private struct PinchZoomPhotoPage: View {
    let uiImage: UIImage

    @State private var scale: CGFloat = 1
    @State private var baseScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastDrag: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: geo.size.width, height: geo.size.height)
                .contentShape(Rectangle())
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let next = baseScale * value
                            scale = min(max(next, 1), 4)
                        }
                        .onEnded { _ in
                            baseScale = min(max(scale, 1), 4)
                            scale = baseScale
                            if scale <= 1.02 {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    offset = .zero
                                    lastDrag = .zero
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { g in
                            guard scale > 1.02 else { return }
                            offset = CGSize(
                                width: lastDrag.width + g.translation.width,
                                height: lastDrag.height + g.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastDrag = offset
                        }
                )
                .simultaneousGesture(
                    TapGesture(count: 2)
                        .onEnded {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                scale = 1
                                baseScale = 1
                                offset = .zero
                                lastDrag = .zero
                            }
                        }
                )
        }
    }
}

// MARK: - Thumbnail tap (reusable)

/// Tappable thumbnail when `resolvedFileNames` is non-empty; otherwise same look without a button.
struct OpelogPhotoThumbnailButton: View {
    let displayFileName: String?
    let category: String
    var status: ItemStatus = .good
    var sideLength: CGFloat
    var cornerRadius: CGFloat
    var neutralPlaceholder: Bool = false
    let resolvedFileNames: [String]
    /// When non-`nil` and there are stored file names, the thumbnail is tappable.
    var onOpenViewer: (() -> Void)? = nil

    private var canOpen: Bool { !resolvedFileNames.isEmpty }

    var body: some View {
        Group {
            if canOpen, let onOpenViewer {
                Button(action: onOpenViewer) {
                    artwork
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.photoViewerTitle)
            } else {
                artwork
            }
        }
    }

    private var artwork: some View {
        ItemArtworkView(
            imageFileName: displayFileName,
            category: category,
            status: status,
            sideLength: sideLength,
            cornerRadius: cornerRadius,
            neutralPlaceholder: neutralPlaceholder
        )
    }
}
