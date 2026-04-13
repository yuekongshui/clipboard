import AppKit
import UniformTypeIdentifiers

enum ClipboardPayload {
    case text(String)
    case image(NSImage)
    case fileURL(URL)
}

extension NSPasteboard {
    func readClipboardPayload() -> ClipboardPayload? {
        if let items = pasteboardItems {
            for item in items {
                if let urlString = item.string(forType: .fileURL),
                   let url = URL(string: urlString) {
                    
                    if let type = try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier,
                       let utType = UTType(type), utType.conforms(to: .image),
                       let image = NSImage(contentsOf: url) {
                        return .image(image)
                    }
                    
                    return .fileURL(url)
                }
            }
        }

        if let image = NSImage(pasteboard: self) {
            return .image(image)
        }

        if let string = string(forType: .string) {
            return .text(string)
        }

        return nil
    }
}

