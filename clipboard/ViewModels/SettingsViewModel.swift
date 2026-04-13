import Foundation
import Combine
import SwiftData

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isConfirmingClearHistory = false
    @Published var isConfirmingClearAllData = false
    @Published var isConfirmingResetCategories = false

    private let storageService = ClipboardStorageService.shared
    private let fileStorage = FileStorageService.shared

    func bootstrap(modelContext: ModelContext) {
        storageService.bootstrapIfNeeded(modelContext: modelContext)
    }

    func save(modelContext: ModelContext) {
        try? modelContext.save()
    }

    func clearHistory(modelContext: ModelContext) {
        storageService.clearAllHistory(modelContext: modelContext)
    }

    func clearImageCache() {
        fileStorage.clearImageCache()
    }

    func resetCategories(modelContext: ModelContext) {
        let categories = (try? modelContext.fetch(FetchDescriptor<Category>())) ?? []
        for category in categories where category.name != "默认分类" {
            storageService.deleteCategory(modelContext: modelContext, category: category)
        }
        _ = storageService.getOrCreateUncategorizedCategory(modelContext: modelContext)
        try? modelContext.save()
    }

    func clearAllData(modelContext: ModelContext) {
        storageService.clearAllData(modelContext: modelContext)
        fileStorage.clearImageCache()
    }
}
