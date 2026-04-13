import Foundation

struct ClipboardQueryState: Equatable {
    var keyword: String = ""
    var selectedType: ClipboardContentType? = nil
    var selectedCategoryID: UUID? = nil
    var favoriteFilter: FavoriteFilter = .all
}

