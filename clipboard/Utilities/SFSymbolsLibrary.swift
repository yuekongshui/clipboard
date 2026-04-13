import Foundation

enum SFSymbolsLibrary {
    static let shared = Loader()

    final class Loader {
        private(set) var names: [String] = []

        init() {
            names = Self.loadFromSystem() ?? Self.fallback
        }

        private static func loadFromSystem() -> [String]? {
            let bundlePath = "/System/Library/CoreServices/CoreGlyphs.bundle"
            let bundle = Bundle(path: bundlePath)
            guard let url = bundle?.url(forResource: "symbol_order", withExtension: "plist") else { return nil }
            guard let data = try? Data(contentsOf: url) else { return nil }
            return (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String]
        }

        private static let fallback: [String] = [
            "tray",
            "tray.full",
            "folder",
            "tag",
            "star",
            "star.fill",
            "bookmark",
            "bookmark.fill",
            "paperclip",
            "doc",
            "doc.text",
            "doc.on.doc",
            "photo",
            "text.alignleft",
            "link",
            "bolt",
            "bell",
            "bell.fill",
            "clock",
            "calendar",
            "pencil",
            "trash",
            "lock",
            "lock.fill",
            "eye",
            "eye.slash",
            "person",
            "person.fill",
            "magnifyingglass",
            "gearshape",
        ]
    }
}

