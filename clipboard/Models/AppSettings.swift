import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID

    var isMonitoringEnabled: Bool
    var isDeduplicationEnabled: Bool
    var isSensitiveFilterEnabled: Bool
    var maxHistoryCount: Int
    var autoCleanDays: Int
    var autoCleanStrategyRawValue: String

    var isImageThumbnailEnabled: Bool

    var themeModeRawValue: String
    var customThemeColorHex: String?

    var blacklistedAppsRawValue: String

    init(
        id: UUID = UUID(),
        isMonitoringEnabled: Bool = true,
        isDeduplicationEnabled: Bool = true,
        isSensitiveFilterEnabled: Bool = true,
        maxHistoryCount: Int = 500,
        autoCleanDays: Int = 30,
        autoCleanStrategy: AutoCleanStrategy = .mixed,
        isImageThumbnailEnabled: Bool = true,
        themeMode: AppThemeMode = .system,
        customThemeColorHex: String? = nil,
        blacklistedAppsRawValue: String = ""
    ) {
        self.id = id
        self.isMonitoringEnabled = isMonitoringEnabled
        self.isDeduplicationEnabled = isDeduplicationEnabled
        self.isSensitiveFilterEnabled = isSensitiveFilterEnabled
        self.maxHistoryCount = maxHistoryCount
        self.autoCleanDays = autoCleanDays
        self.autoCleanStrategyRawValue = autoCleanStrategy.rawValue
        self.isImageThumbnailEnabled = isImageThumbnailEnabled
        self.themeModeRawValue = themeMode.rawValue
        self.customThemeColorHex = customThemeColorHex
        self.blacklistedAppsRawValue = blacklistedAppsRawValue
    }
}

extension AppSettings {
    var autoCleanStrategy: AutoCleanStrategy {
        get { AutoCleanStrategy(rawValue: autoCleanStrategyRawValue) ?? .mixed }
        set { autoCleanStrategyRawValue = newValue.rawValue }
    }

    var blacklistedApps: [String] {
        get {
            blacklistedAppsRawValue
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        set {
            blacklistedAppsRawValue = newValue.joined(separator: "\n")
        }
    }

    var themeMode: AppThemeMode {
        get { AppThemeMode(rawValue: themeModeRawValue) ?? .system }
        set { themeModeRawValue = newValue.rawValue }
    }
}
