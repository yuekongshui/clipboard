import AppKit

@MainActor
final class ClipboardInternalChangeTracker {
    static let shared = ClipboardInternalChangeTracker()

    private var ignoredChangeCounts: Set<Int> = []

    func markInternalChange(pasteboard: NSPasteboard) {
        ignoredChangeCounts.insert(pasteboard.changeCount)
    }

    func shouldIgnore(changeCount: Int) -> Bool {
        if ignoredChangeCounts.contains(changeCount) {
            ignoredChangeCounts.remove(changeCount)
            return true
        }
        return false
    }
}

