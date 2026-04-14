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
                .navigationSplitViewColumnWidth(min: 650, ideal: 700, max: 8050)
        } detail: {
            DetailView(selectedItemID: $viewModel.selectedItemID)
                .navigationSplitViewColumnWidth(min: 400, ideal: 450)
        }
        .task {
            viewModel.start(modelContext: modelContext)
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}
