import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        if let settings = settingsList.first {
            TabView {
                GeneralSettingsView(viewModel: viewModel, settings: settings)
                    .tabItem { Label("通用", systemImage: "gearshape") }
                PrivacySettingsView(viewModel: viewModel, settings: settings)
                    .tabItem { Label("隐私", systemImage: "hand.raised") }
                DisplaySettingsView(viewModel: viewModel, settings: settings)
                    .tabItem { Label("显示", systemImage: "display") }
                DataSettingsView(viewModel: viewModel)
                    .tabItem { Label("数据", systemImage: "externaldrive") }
            }
            .padding(12)
            .frame(width: 520, height: 360)
        } else {
            ProgressView()
                .task {
                    viewModel.bootstrap(modelContext: modelContext)
                }
        }
    }
}
