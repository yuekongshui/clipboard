import AppKit
import Foundation

@MainActor
final class FileStorageService {
    static let shared = FileStorageService()

    private let imagesDirectoryName = "ClipboardImages"

    func imagesDirectoryURL() throws -> URL {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let bundleID = Bundle.main.bundleIdentifier ?? "clipboard"
        let root = appSupport.appendingPathComponent(bundleID, isDirectory: true)
        let dir = root.appendingPathComponent(imagesDirectoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func saveImage(_ image: NSImage) throws -> (path: String, width: Double, height: Double) {
        let dir = try imagesDirectoryURL()
        let fileURL = dir.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")

        guard let data = image.pngData() else {
            throw NSError(domain: "FileStorageService", code: 1)
        }

        try data.write(to: fileURL, options: [.atomic])

        let size = image.size
        return (fileURL.path, Double(size.width), Double(size.height))
    }

    func removeImageIfExists(path: String?) {
        guard let path, !path.isEmpty else { return }
        try? FileManager.default.removeItem(atPath: path)
    }

    func clearImageCache() {
        guard let dir = try? imagesDirectoryURL() else { return }
        try? FileManager.default.removeItem(at: dir)
        _ = try? imagesDirectoryURL()
    }
}

