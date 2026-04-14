import SwiftUI
import SwiftData

struct RootSplitView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var queryState: ClipboardQueryState = ClipboardQueryState()
    @State private var selectedItemID: UUID?

    @StateObject private var viewModel = RootViewModel()

    var body: some View {
        NavigationSplitView {
            SidebarView(queryState: $queryState)
                .navigationSplitViewColumnWidth(min: 150, ideal: 200, max: 250)
        } content: {
            HistoryListView(queryState: $queryState, selectedItemID: $selectedItemID)
                .navigationSplitViewColumnWidth(min: 650, ideal: 700, max: 8050)
        } detail: {
            DetailView(selectedItemID: $selectedItemID)
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
