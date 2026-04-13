import Foundation
import Combine
import SwiftData

@MainActor
final class DetailViewModel: ObservableObject {
    private let storageService = ClipboardStorageService.shared

    func selectedItem(items: [ClipboardItem], selectedItemID: UUID?) -> ClipboardItem? {
        guard let selectedItemID else { return nil }
        return items.first(where: { $0.id == selectedItemID })
    }

    func copy(item: ClipboardItem, modelContext: ModelContext) {
        storageService.copyItemToPasteboard(modelContext: modelContext, item: item)
    }

    func toggleFavorite(item: ClipboardItem, modelContext: ModelContext) {
        storageService.toggleFavorite(modelContext: modelContext, item: item)
    }

    func delete(item: ClipboardItem, modelContext: ModelContext) {
        storageService.deleteItem(modelContext: modelContext, item: item)
    }
}
