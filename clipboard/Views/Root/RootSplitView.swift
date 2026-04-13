import SwiftUI
import SwiftData

struct RootSplitView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = RootViewModel()

    var body: some View {
        NavigationSplitView {
            SidebarView(queryState: $viewModel.queryState)
                .navigationSplitViewColumnWidth(min: 150, ideal: 200, max: 250)
        } content: {
            HistoryListView(queryState: $viewModel.queryState, selectedItemID: $viewModel.selectedItemID)
                .navigationSplitViewColumnWidth(min: 300, ideal: 350, max: 500)
        } detail: {
            DetailView(selectedItemID: $viewModel.selectedItemID)
        }
        .task {
            viewModel.start(modelContext: modelContext)
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}
