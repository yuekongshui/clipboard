import Foundation
import Combine
import SwiftData

@MainActor
final class HistoryListViewModel: ObservableObject {
    @Published var isConfirmingClearAll: Bool = false

    private let storageService = ClipboardStorageService.shared

    func filteredItems(items: [ClipboardItem], queryState: ClipboardQueryState, uncategorizedID: UUID) -> [ClipboardItem] {
        let keyword = queryState.keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let selectedType = queryState.selectedType
        let selectedCategoryID = queryState.selectedCategoryID
        let favoriteFilter = queryState.favoriteFilter

        return items.filter { item in
            if let selectedType, item.type != selectedType {
                return false
            }

            if let selectedCategoryID {
                let currentID = item.category?.id ?? uncategorizedID
                if currentID != selectedCategoryID {
                    return false
                }
            }

            switch favoriteFilter {
            case .all:
                break
            case .favoriteOnly:
                if !item.isFavorite { return false }
            case .nonFavoriteOnly:
                if item.isFavorite { return false }
            }

            if keyword.isEmpty { return true }

            let fields: [String] = [
                item.previewText,
                item.textContent ?? "",
                item.fileName ?? "",
                item.filePath ?? "",
                item.category?.name ?? "",
                item.sourceAppName ?? ""
            ]

            return fields.contains { $0.lowercased().contains(keyword) }
        }
    }

    func copy(item: ClipboardItem, modelContext: ModelContext) {
        storageService.copyItemToPasteboard(modelContext: modelContext, item: item)
    }

    func toggleFavorite(item: ClipboardItem, modelContext: ModelContext) {
        storageService.toggleFavorite(modelContext: modelContext, item: item)
    }

    func move(item: ClipboardItem, to category: Category?, modelContext: ModelContext) {
        storageService.updateCategoryForItem(modelContext: modelContext, item: item, category: category)
    }

    func delete(item: ClipboardItem, modelContext: ModelContext) {
        storageService.deleteItem(modelContext: modelContext, item: item)
    }

    func delete(items: [ClipboardItem], modelContext: ModelContext) {
        storageService.deleteItems(modelContext: modelContext, items: items)
    }

    func clearAll(modelContext: ModelContext) {
        storageService.clearAllHistory(modelContext: modelContext)
    }
}
