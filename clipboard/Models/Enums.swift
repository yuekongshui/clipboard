import Foundation

enum ClipboardContentType: String, Codable, CaseIterable {
    case text
    case image
    case file
}

enum FavoriteFilter: String, CaseIterable {
    case all
    case favoriteOnly
    case nonFavoriteOnly
}

enum AutoCleanStrategy: String, Codable, CaseIterable {
    case none
    case byCount
    case byDays
    case mixed
}

enum AppThemeMode: String, Codable, CaseIterable {
    case system
    case light
    case dark
    case custom
}

enum AppLanguage: String, Codable, CaseIterable {
    case system
    case zh = "zh-Hans"
    case en
    case ja
    
    var locale: Locale? {
        switch self {
        case .system:
            return nil
        default:
            return Locale(identifier: rawValue)
        }
    }
}

