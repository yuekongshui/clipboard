import Foundation
import SwiftData

@Model
final class ClipboardItem {
    var id: UUID
    var typeRawValue: String

    var previewText: String
    var createdAt: Date
    var updatedAt: Date
    var lastUsedAt: Date?
    var sourceAppName: String?
    var isFavorite: Bool
    var isSensitive: Bool
    var isDeleted: Bool

    var textContent: String?

    var imageLocalPath: String?
    var imageWidth: Double?
    var imageHeight: Double?

    var filePath: String?
    var fileName: String?
    var fileUTI: String?
    var fileSize: Int64?

    var category: Category?

    init(
        id: UUID = UUID(),
        type: ClipboardContentType,
        previewText: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        lastUsedAt: Date? = nil,
        sourceAppName: String? = nil,
        isFavorite: Bool = false,
        isSensitive: Bool = false,
        isDeleted: Bool = false,
        textContent: String? = nil,
        imageLocalPath: String? = nil,
        imageWidth: Double? = nil,
        imageHeight: Double? = nil,
        filePath: String? = nil,
        fileName: String? = nil,
        fileUTI: String? = nil,
        fileSize: Int64? = nil,
        category: Category? = nil
    ) {
        self.id = id
        self.typeRawValue = type.rawValue
        self.previewText = previewText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastUsedAt = lastUsedAt
        self.sourceAppName = sourceAppName
        self.isFavorite = isFavorite
        self.isSensitive = isSensitive
        self.isDeleted = isDeleted
        self.textContent = textContent
        self.imageLocalPath = imageLocalPath
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.filePath = filePath
        self.fileName = fileName
        self.fileUTI = fileUTI
        self.fileSize = fileSize
        self.category = category
    }
}

extension ClipboardItem {
    var type: ClipboardContentType {
        get { ClipboardContentType(rawValue: typeRawValue) ?? .text }
        set { typeRawValue = newValue.rawValue }
    }
}

