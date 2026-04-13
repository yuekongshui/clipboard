import AppKit
import Combine
import Foundation
import SwiftData

@MainActor
final class ClipboardMonitorService: ObservableObject {
    static let shared = ClipboardMonitorService()

    @Published private(set) var isRunning: Bool = false

    private var timer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount
    private var modelContext: ModelContext?

    private let storageService = ClipboardStorageService.shared
    private let privacyService = PrivacyFilterService()

    private let pollInterval: TimeInterval = 0.6
    private let dedupInterval: TimeInterval = 2.0

    func start(modelContext: ModelContext) {
        guard timer == nil else { return }
        isRunning = true
        lastChangeCount = NSPasteboard.general.changeCount
        self.modelContext = modelContext

        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.pollIfPossible()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        modelContext = nil
    }

    private func pollIfPossible() {
        guard let modelContext else { return }
        let pasteboard = NSPasteboard.general
        let changeCount = pasteboard.changeCount
        if changeCount == lastChangeCount { return }
        lastChangeCount = changeCount

        if ClipboardInternalChangeTracker.shared.shouldIgnore(changeCount: changeCount) {
            return
        }

        let settings = storageService.getOrCreateSettings(modelContext: modelContext)
        if !settings.isMonitoringEnabled { return }

        guard let payload = pasteboard.readClipboardPayload() else { return }

        let sourceAppName = NSWorkspace.shared.frontmostApplication?.localizedName

        if privacyService.isBlacklisted(appName: sourceAppName, settings: settings) {
            return
        }

        var isSensitive = false
        if case .text(let text) = payload {
            isSensitive = privacyService.isSensitive(text: text)
            if settings.isSensitiveFilterEnabled, isSensitive {
                return
            }
        }

        if settings.isDeduplicationEnabled {
            let preview = previewText(for: payload)
            let type = contentType(for: payload)
            if shouldDeduplicate(modelContext: modelContext, type: type, previewText: preview) {
                return
            }
        }

        storageService.addItemFromPayload(
            modelContext: modelContext,
            payload: payload,
            sourceAppName: sourceAppName,
            settings: settings,
            isSensitive: isSensitive
        )
    }

    private func shouldDeduplicate(modelContext: ModelContext, type: ClipboardContentType, previewText: String) -> Bool {
        var descriptor = FetchDescriptor<ClipboardItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        guard let latest = try? modelContext.fetch(descriptor).first else { return false }
        guard latest.type == type else { return false }
        guard latest.previewText == previewText else { return false }
        return Date().timeIntervalSince(latest.createdAt) < dedupInterval
    }

    private func contentType(for payload: ClipboardPayload) -> ClipboardContentType {
        switch payload {
        case .text:
            return .text
        case .image:
            return .image
        case .fileURL:
            return .file
        }
    }

    private func previewText(for payload: ClipboardPayload) -> String {
        switch payload {
        case .text(let text):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let singleLine = trimmed.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            if singleLine.count <= 120 { return singleLine }
            let idx = singleLine.index(singleLine.startIndex, offsetBy: 120)
            return String(singleLine[..<idx]) + "…"
        case .image(let image):
            let size = image.size
            return "图片 \(Int(size.width))×\(Int(size.height))"
        case .fileURL(let url):
            return url.lastPathComponent
        }
    }
}
