import SwiftUI
import SwiftData

struct CategoryEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allCategories: [Category]

    let category: Category?

    @State private var name: String
    @State private var iconName: String
    @State private var isUsingColor: Bool
    @State private var color: Color

    @State private var isPresentingSymbolPicker = false

    private let storageService = ClipboardStorageService.shared

    init(category: Category?) {
        self.category = category
        _name = State(initialValue: category?.name ?? "")
        _iconName = State(initialValue: category?.iconName ?? "")
        let initialHex = category?.colorHex
        let initialColor = Color(hex: initialHex) ?? .accentColor
        _isUsingColor = State(initialValue: Color(hex: initialHex) != nil)
        _color = State(initialValue: initialColor)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category == nil ? "新建分类" : "编辑分类")
                .font(.title2)

            Form {
                TextField("名称", text: $name)
                    .disabled(isDefaultCategory)

                if isNameDuplicate {
                    Text("分类名称已存在")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                HStack {
                    Text("图标")
                    Spacer()
                    Image(systemName: previewSymbolName)
                        .frame(width: 18)
                    Text(previewSymbolName)
                        .foregroundStyle(.secondary)
                    Button("选择") {
                        isPresentingSymbolPicker = true
                    }
                }

                if isUsingColor {
                    HStack {
                        ColorPicker("颜色", selection: $color, supportsOpacity: false)
                        Button("清除") {
                            isUsingColor = false
                        }
                    }
                } else {
                    Button("选择颜色") {
                        isUsingColor = true
                    }
                }
            }

            HStack {
                Spacer()
                Button("取消") {
                    dismiss()
                }
                Button("保存") {
                    save()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canSave)
            }
        }
        .padding(16)
        .frame(width: 420)
        .sheet(isPresented: $isPresentingSymbolPicker) {
            SFSymbolPickerSheet(symbolName: $iconName)
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let icon = iconName.trimmingCharacters(in: .whitespacesAndNewlines)

        let iconValue = icon.isEmpty ? nil : icon
        let colorValue = isUsingColor ? color.hexString() : nil

        if let category {
            storageService.updateCategory(modelContext: modelContext, category: category, name: trimmedName, iconName: iconValue, colorHex: colorValue)
        } else {
            _ = storageService.createCategory(modelContext: modelContext, name: trimmedName, iconName: iconValue, colorHex: colorValue)
        }
    }

    private var previewSymbolName: String {
        let trimmed = iconName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "folder" : trimmed
    }

    private var isNameDuplicate: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let category = category, category.name == trimmedName {
            return false
        }
        return allCategories.contains { $0.name == trimmedName }
    }

    private var isDefaultCategory: Bool {
        category?.name == "默认分类"
    }

    private var canSave: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty { return false }
        if isNameDuplicate { return false }
        return true
    }
}
