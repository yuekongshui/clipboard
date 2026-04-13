import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ClipboardItem]

    @Binding var selectedItemID: UUID?

    @StateObject private var viewModel = DetailViewModel()

    var body: some View {
        if let item = viewModel.selectedItem(items: items, selectedItemID: selectedItemID) {
            Group {
                switch item.type {
                case .text:
                    TextDetailView(item: item)
                case .image:
                    ImageDetailView(item: item)
                case .file:
                    FileDetailView(item: item)
                }
            }
            .toolbar {
                ToolbarItemGroup {
                    Button("复制") {
                        viewModel.copy(item: item, modelContext: modelContext)
                    }
                    Button(item.isFavorite ? "取消收藏" : "收藏") {
                        viewModel.toggleFavorite(item: item, modelContext: modelContext)
                    }
                    Button("删除", role: .destructive) {
                        viewModel.delete(item: item, modelContext: modelContext)
                        selectedItemID = nil
                    }
                }
            }
        } else {
            ContentUnavailableView("选择一条记录查看详情", systemImage: "doc.text.magnifyingglass", description: Text("左侧列表中选择一条剪贴板历史记录。"))
        }
    }
}
