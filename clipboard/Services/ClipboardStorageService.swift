import AppKit
import Foundation
import SwiftData

@MainActor
final class ClipboardStorageService {
    static let shared = ClipboardStorageService()

    private let fileStorage = FileStorageService.shared

    func bootstrapIfNeeded(modelContext: ModelContext) {
        _ = getOrCreateSettings(modelContext: modelContext)
        _ = getOrCreateUncategorizedCategory(modelContext: modelContext)
        try? modelContext.save()
    }

    func getOrCreateSettings(modelContext: ModelContext) -> AppSettings {
        var descriptor = FetchDescriptor<AppSettings>()
        descriptor.fetchLimit = 1
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let settings = AppSettings()
        modelContext.insert(settings)
        return settings
    }

    func getOrCreateUncategorizedCategory(modelContext: ModelContext) -> Category {
        let predicate = #Predicate<Category> { $0.name == "默认分类" || $0.name == "未分类" }
        var descriptor = FetchDescriptor<Category>(predicate: predicate)
        descriptor.fetchLimit = 1
        if let existing = try? modelContext.fetch(descriptor).first {
            if existing.name == "未分类" {
                existing.name = "默认分类"
                try? modelContext.save()
            }
            return existing
        }
        let category = Category(name: "默认分类", iconName: "tray", colorHex: nil)
        modelContext.insert(category)
        return category
    }

    func createCategory(modelContext: ModelContext, name: String, iconName: String?, colorHex: String?) -> Category {
        let category = Category(name: name, iconName: iconName, colorHex: colorHex)
        modelContext.insert(category)
        try? modelContext.save()
        return category
    }

    func updateCategory(modelContext: ModelContext, category: Category, name: String, iconName: String?, colorHex: String?) {
        category.name = name
        category.iconName = iconName
        category.colorHex = colorHex
        try? modelContext.save()
    }

    func deleteCategory(modelContext: ModelContext, category: Category) {
        let uncategorized = getOrCreateUncategorizedCategory(modelContext: modelContext)
        for item in category.items {
            item.category = uncategorized
            item.updatedAt = .now
        }
        modelContext.delete(category)
        try? modelContext.save()
    }

    func toggleFavorite(modelContext: ModelContext, item: ClipboardItem) {
        item.isFavorite.toggle()
        item.updatedAt = .now
        try? modelContext.save()
    }

    func updateCategoryForItem(modelContext: ModelContext, item: ClipboardItem, category: Category?) {
        item.category = category
        item.updatedAt = .now
        try? modelContext.save()
    }

    func deleteItem(modelContext: ModelContext, item: ClipboardItem) {
        if item.type == .image {
            fileStorage.removeImageIfExists(path: item.imageLocalPath)
        }
        modelContext.delete(item)
        try? modelContext.save()
    }

    func deleteItems(modelContext: ModelContext, items: [ClipboardItem]) {
        for item in items {
            if item.type == .image {
                fileStorage.removeImageIfExists(path: item.imageLocalPath)
            }
            modelContext.delete(item)
        }
        try? modelContext.save()
    }

    func clearAllHistory(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<ClipboardItem>()
        let items = (try? modelContext.fetch(descriptor)) ?? []
        deleteItems(modelContext: modelContext, items: items)
    }

    func clearAllData(modelContext: ModelContext) {
        clearAllHistory(modelContext: modelContext)

        let categories = (try? modelContext.fetch(FetchDescriptor<Category>())) ?? []
        for category in categories {
            modelContext.delete(category)
        }

        let settings = (try? modelContext.fetch(FetchDescriptor<AppSettings>())) ?? []
        for setting in settings {
            modelContext.delete(setting)
        }

        try? modelContext.save()
        bootstrapIfNeeded(modelContext: modelContext)
    }

    func addItemFromPayload(
        modelContext: ModelContext,
        payload: ClipboardPayload,
        sourceAppName: String?,
        settings: AppSettings,
        isSensitive: Bool
    ) {
        let uncategorized = getOrCreateUncategorizedCategory(modelContext: modelContext)

        switch payload {
        case .text(let text):
            let preview = makeTextPreview(text)
            let item = ClipboardItem(
                type: .text,
                previewText: preview,
                sourceAppName: sourceAppName,
                isSensitive: isSensitive,
                textContent: text,
                category: uncategorized
            )
            modelContext.insert(item)
        case .image(let image):
            guard let saved = try? fileStorage.saveImage(image) else { return }
            let preview = "图片 \(Int(saved.width))×\(Int(saved.height))"
            let item = ClipboardItem(
                type: .image,
                previewText: preview,
                sourceAppName: sourceAppName,
                imageLocalPath: saved.path,
                imageWidth: saved.width,
                imageHeight: saved.height,
                category: uncategorized
            )
            modelContext.insert(item)
        case .fileURL(let url):
            let values = try? url.resourceValues(forKeys: [.typeIdentifierKey, .fileSizeKey, .isDirectoryKey])
            let fileName = url.lastPathComponent
            let uti = values?.typeIdentifier
            let size = Int64(values?.fileSize ?? 0)
            let preview = fileName
            let item = ClipboardItem(
                type: .file,
                previewText: preview,
                sourceAppName: sourceAppName,
                filePath: url.path,
                fileName: fileName,
                fileUTI: uti,
                fileSize: size,
                category: uncategorized
            )
            modelContext.insert(item)
        }

        try? modelContext.save()
        autoCleanIfNeeded(modelContext: modelContext, settings: settings)
    }

    func autoCleanIfNeeded(modelContext: ModelContext, settings: AppSettings) {
        guard settings.autoCleanStrategy != .none else { return }

        let now = Date()
        let allItems = (try? modelContext.fetch(FetchDescriptor<ClipboardItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))) ?? []
        if allItems.isEmpty { return }

        var toDelete: [ClipboardItem] = []

        if settings.autoCleanStrategy == .byDays || settings.autoCleanStrategy == .mixed {
            let days = max(1, settings.autoCleanDays)
            let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: now) ?? now
            let dayCandidates = allItems.filter { !$0.isFavorite && $0.createdAt < cutoff }
            toDelete.append(contentsOf: dayCandidates)
        }

        if settings.autoCleanStrategy == .byCount || settings.autoCleanStrategy == .mixed {
            let maxCount = max(50, settings.maxHistoryCount)
            if allItems.count > maxCount {
                let sortedOldestFirst = allItems.sorted { $0.createdAt < $1.createdAt }
                var remaining = allItems.count - maxCount

                let nonFavorites = sortedOldestFirst.filter { !$0.isFavorite }
                for item in nonFavorites {
                    if remaining <= 0 { break }
                    if !toDelete.contains(where: { $0.id == item.id }) {
                        toDelete.append(item)
                        remaining -= 1
                    }
                }

                if remaining > 0 {
                    let favorites = sortedOldestFirst.filter { $0.isFavorite }
                    for item in favorites {
                        if remaining <= 0 { break }
                        if !toDelete.contains(where: { $0.id == item.id }) {
                            toDelete.append(item)
                            remaining -= 1
                        }
                    }
                }
            }
        }

        if !toDelete.isEmpty {
            deleteItems(modelContext: modelContext, items: toDelete)
        }
    }

    func copyItemToPasteboard(modelContext: ModelContext, item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.type {
        case .text:
            guard let text = item.textContent else { return }
            pasteboard.setString(text, forType: .string)
        case .image:
            guard let path = item.imageLocalPath, let image = NSImage.loadFromFile(path: path) else { return }
            pasteboard.writeObjects([image])
        case .file:
            guard let path = item.filePath else { return }
            let url = URL(fileURLWithPath: path)
            pasteboard.writeObjects([url as NSURL])
        }

        ClipboardInternalChangeTracker.shared.markInternalChange(pasteboard: pasteboard)

        item.lastUsedAt = .now
        item.updatedAt = .now
        try? modelContext.save()
    }

    private func makeTextPreview(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let singleLine = trimmed.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        if singleLine.count <= 120 { return singleLine }
        let idx = singleLine.index(singleLine.startIndex, offsetBy: 120)
        return String(singleLine[..<idx]) + "…"
    }
}
