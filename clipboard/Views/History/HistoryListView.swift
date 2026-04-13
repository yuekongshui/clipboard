import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClipboardItem.createdAt, order: .reverse) private var items: [ClipboardItem]
    @Query(sort: \Category.createdAt, order: .forward) private var categories: [Category]

    @Binding var queryState: ClipboardQueryState
    @Binding var selectedItemID: UUID?

    @StateObject private var viewModel = HistoryListViewModel()
    private let storageService = ClipboardStorageService.shared

    var body: some View {
        VStack(spacing: 0) {
            controls
                .padding(.horizontal, 12)
                .padding(.vertical, 10)

            List(selection: $selectedItemID) {
                ForEach(filteredItems) { item in
                    ClipboardRowView(
                        item: item
                    )
                    .tag(item.id)
                    .contextMenu {
                        Button("复制") {
                            viewModel.copy(item: item, modelContext: modelContext)
                        }
                        Button(item.isFavorite ? "取消收藏" : "收藏") {
                            viewModel.toggleFavorite(item: item, modelContext: modelContext)
                        }
                        Menu("移动到分类") {
                            ForEach(categories) { category in
                                Button(category.name) {
                                    viewModel.move(item: item, to: category, modelContext: modelContext)
                                }
                            }
                        }
                        Divider()
                        Button("删除", role: .destructive) {
                            viewModel.delete(item: item, modelContext: modelContext)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button("清空全部") {
                    viewModel.isConfirmingClearAll = true
                }
            }
        }
        .alert("清空全部历史？", isPresented: $viewModel.isConfirmingClearAll) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                viewModel.clearAll(modelContext: modelContext)
                selectedItemID = nil
            }
        } message: {
            Text("该操作不可撤销。")
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            TextField("搜索", text: $queryState.keyword)
                .textFieldStyle(.roundedBorder)

            Picker("类型", selection: Binding(get: { queryState.selectedType }, set: { queryState.selectedType = $0 })) {
                Text("全部").tag(ClipboardContentType?.none)
                Text("文本").tag(ClipboardContentType?.some(.text))
                Text("图片").tag(ClipboardContentType?.some(.image))
                Text("文件").tag(ClipboardContentType?.some(.file))
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 320)

            Picker("收藏", selection: $queryState.favoriteFilter) {
                Text("全部").tag(FavoriteFilter.all)
                Text("仅收藏").tag(FavoriteFilter.favoriteOnly)
                Text("未收藏").tag(FavoriteFilter.nonFavoriteOnly)
            }
            .pickerStyle(.menu)
        }
    }

    private var filteredItems: [ClipboardItem] {
        let uncategorizedID = categories.first { $0.name == "默认分类" }?.id ?? UUID()
        return viewModel.filteredItems(items: items, queryState: queryState, uncategorizedID: uncategorizedID)
    }

    private func delete(offsets: IndexSet) {
        let targets = offsets.compactMap { idx in
            filteredItems.indices.contains(idx) ? filteredItems[idx] : nil
        }
        viewModel.delete(items: targets, modelContext: modelContext)
    }
}
