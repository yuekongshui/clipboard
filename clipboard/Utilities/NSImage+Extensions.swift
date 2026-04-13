import AppKit

extension NSImage {
    func pngData() -> Data? {
        guard let tiff = tiffRepresentation else { return nil }
        guard let bitmap = NSBitmapImageRep(data: tiff) else { return nil }
        return bitmap.representation(using: .png, properties: [:])
    }

    static func loadFromFile(path: String) -> NSImage? {
        NSImage(contentsOfFile: path)
    }
}

