import Foundation

@MainActor
final class PrivacyFilterService {
    func isBlacklisted(appName: String?, settings: AppSettings) -> Bool {
        guard let appName, !appName.isEmpty else { return false }
        let lowered = appName.lowercased()
        return settings.blacklistedApps.contains { $0.lowercased() == lowered }
    }

    func isSensitive(text: String) -> Bool {
        text.isSensitiveClipboardText()
    }
}

