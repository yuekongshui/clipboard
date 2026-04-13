import Foundation
import Combine
import SwiftData

enum SidebarSelection: Hashable {
    case all
    case favorites
    case type(ClipboardContentType?)
    case category(UUID)

    static func from(queryState: ClipboardQueryState) -> SidebarSelection {
        if queryState.favoriteFilter == .favoriteOnly && queryState.selectedCategoryID == nil && queryState.selectedType == nil {
            return .favorites
        }
        if let categoryID = queryState.selectedCategoryID {
            return .category(categoryID)
        }
        return .type(queryState.selectedType)
    }

    func apply(to state: ClipboardQueryState) -> ClipboardQueryState {
        var newState = state
        switch self {
        case .all:
            newState.keyword = ""
            newState.selectedType = nil
            newState.selectedCategoryID = nil
            newState.favoriteFilter = .all
        case .favorites:
            newState.selectedType = nil
            newState.selectedCategoryID = nil
            newState.favoriteFilter = .favoriteOnly
        case .type(let type):
            newState.selectedType = type
            newState.selectedCategoryID = nil
            newState.favoriteFilter = .all
        case .category(let id):
            newState.selectedCategoryID = id
            newState.favoriteFilter = .all
        }
        return newState
    }
}

@MainActor
final class SidebarViewModel: ObservableObject {
    @Published var selection: SidebarSelection = .type(nil)

    @Published var isPresentingEditor: Bool = false
    @Published var editingCategory: Category?
    @Published var deletingCategory: Category?

    private let storageService = ClipboardStorageService.shared

    func syncFromQueryState(_ queryState: ClipboardQueryState) {
        selection = SidebarSelection.from(queryState: queryState)
    }

    func applySelection(to queryState: ClipboardQueryState) -> ClipboardQueryState {
        selection.apply(to: queryState)
    }

    func beginCreateCategory() {
        editingCategory = nil
        isPresentingEditor = true
    }

    func beginEditCategory(_ category: Category) {
        editingCategory = category
        isPresentingEditor = true
    }

    func requestDeleteCategory(_ category: Category) {
        deletingCategory = category
    }

    func confirmDeleteCategoryIfNeeded(modelContext: ModelContext) {
        guard let deletingCategory else { return }
        storageService.deleteCategory(modelContext: modelContext, category: deletingCategory)
        self.deletingCategory = nil
    }
}
