import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var iconName: String?
    var colorHex: String?
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \ClipboardItem.category)
    var items: [ClipboardItem]

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String? = nil,
        colorHex: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.items = []
    }
}

