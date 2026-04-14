import Foundation
import Combine
import SwiftData

@MainActor
final class RootViewModel: ObservableObject {
    private let storageService = ClipboardStorageService.shared
    private let monitor = ClipboardMonitorService.shared

    private var didStart = false

    func start(modelContext: ModelContext) {
        guard !didStart else { return }
        didStart = true
        storageService.bootstrapIfNeeded(modelContext: modelContext)
        monitor.start(modelContext: modelContext)
    }

    func stop() {
        monitor.stop()
        didStart = false
    }
}
