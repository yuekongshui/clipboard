import SwiftUI
import SwiftData

struct DataSettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("危险操作") {
                Button("清空历史记录", role: .destructive) {
                    viewModel.isConfirmingClearHistory = true
                }
                Button("清空图片缓存", role: .destructive) {
                    viewModel.clearImageCache()
                }
                Button("重建默认分类", role: .destructive) {
                    viewModel.isConfirmingResetCategories = true
                }
                Button("清空全部数据（数据库）", role: .destructive) {
                    viewModel.isConfirmingClearAllData = true
                }
            }
        }
        .formStyle(.grouped)
        .alert("清空历史记录？", isPresented: $viewModel.isConfirmingClearHistory) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                viewModel.clearHistory(modelContext: modelContext)
            }
        } message: {
            Text("该操作不可撤销。")
        }
        .alert("重建默认分类？", isPresented: $viewModel.isConfirmingResetCategories) {
            Button("取消", role: .cancel) {}
            Button("重建", role: .destructive) {
                viewModel.resetCategories(modelContext: modelContext)
            }
        } message: {
            Text("会删除除“默认分类”外的所有分类，但不会删除历史记录。")
        }
        .alert("清空全部数据？", isPresented: $viewModel.isConfirmingClearAllData) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                viewModel.clearAllData(modelContext: modelContext)
            }
        } message: {
            Text("该操作不可撤销，会删除全部历史记录、分类和设置。")
        }
    }
}
