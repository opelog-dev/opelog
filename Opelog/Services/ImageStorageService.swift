import Foundation
import UIKit

enum ImageStorageError: Error {
    case invalidImageData
}

/// Saves item photos under the app Documents directory. Only file names are stored in SwiftData.
enum ImageStorageService {
    private static let folderName = "OpelogItemImages"

    private static func imagesDirectoryURL() throws -> URL {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ImageStorageError.invalidImageData
        }
        let dir = docs.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    /// Resolves a stored file name to a file URL if the file exists. Rejects path tricks.
    static func fileURL(for fileName: String) -> URL? {
        let trimmed = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard !trimmed.contains("/"), !trimmed.contains("..") else { return nil }
        guard let base = try? imagesDirectoryURL() else { return nil }
        let url = base.appendingPathComponent(trimmed)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    static func loadUIImage(fileName: String) -> UIImage? {
        guard let url = fileURL(for: fileName) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    /// Writes JPEG to disk and returns the file name (not a full path).
    static func saveImage(data: Data) throws -> String {
        guard let image = UIImage(data: data),
              let jpeg = image.jpegData(compressionQuality: 0.86) else {
            throw ImageStorageError.invalidImageData
        }
        let dir = try imagesDirectoryURL()
        let name = UUID().uuidString + ".jpg"
        let url = dir.appendingPathComponent(name)
        try jpeg.write(to: url, options: .atomic)
        return name
    }

    static func deleteImage(fileName: String?) {
        guard let name = fileName, let url = fileURL(for: name) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
