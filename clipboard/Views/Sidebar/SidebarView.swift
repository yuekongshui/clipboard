import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.createdAt, order: .forward) private var categories: [Category]

    @Binding var queryState: ClipboardQueryState

    @StateObject private var viewModel = SidebarViewModel()
    private let storageService = ClipboardStorageService.shared

    private var sortedCategories: [Category] {
        var result = categories
        if let idx = result.firstIndex(where: { $0.name == "默认分类" }) {
            let defaultCat = result.remove(at: idx)
            result.insert(defaultCat, at: 0)
        }
        return result
    }

    var body: some View {
        List(selection: $viewModel.selection) {
            Section("快捷入口") {
                Label("全部记录", systemImage: "tray.full")
                    .tag(SidebarSelection.all)
                Label("仅收藏", systemImage: "star.fill")
                    .tag(SidebarSelection.favorites)
            }

            Section("类型") {
                Label("全部", systemImage: "square.stack.3d.down.right")
                    .tag(SidebarSelection.type(nil))
                Label("文本", systemImage: "text.alignleft")
                    .tag(SidebarSelection.type(.text))
                Label("图片", systemImage: "photo")
                    .tag(SidebarSelection.type(.image))
                Label("文件", systemImage: "doc")
                    .tag(SidebarSelection.type(.file))
            }

            Section {
                ForEach(sortedCategories) { category in
                    HStack(spacing: 8) {
                        if let color = Color(hex: category.colorHex) {
                            Circle().fill(color).frame(width: 8, height: 8)
                        }
                        Label(category.name, systemImage: category.iconName ?? "folder")
                    }
                    .tag(SidebarSelection.category(category.id))
                    .contextMenu {
                        Button("编辑") {
                            viewModel.beginEditCategory(category)
                        }
                        if category.name != "默认分类" {
                            Button("删除") {
                                viewModel.requestDeleteCategory(category)
                            }
                        }
                    }
                }
            } header: {
                Text("分类")
            } footer: {
                Button("新建分类") {
                    viewModel.beginCreateCategory()
                }
                .buttonStyle(.link)
            }
        }
        .navigationTitle("Clipboard")
        .toolbar {
            Button {
                viewModel.beginCreateCategory()
            } label: {
                Label("新建分类", systemImage: "plus")
            }
        }
        .sheet(isPresented: $viewModel.isPresentingEditor) {
            CategoryEditorSheet(category: viewModel.editingCategory)
        }
        .alert("删除分类？", isPresented: Binding(get: { viewModel.deletingCategory != nil }, set: { if !$0 { viewModel.deletingCategory = nil } })) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                viewModel.confirmDeleteCategoryIfNeeded(modelContext: modelContext)
            }
        } message: {
            Text("该分类下记录不会被删除，会迁移到“默认分类”。")
        }
        .onAppear {
            storageService.bootstrapIfNeeded(modelContext: modelContext)
            viewModel.syncFromQueryState(queryState)
        }
        .onChange(of: viewModel.selection) {
            queryState = viewModel.applySelection(to: queryState)
        }
    }
}
