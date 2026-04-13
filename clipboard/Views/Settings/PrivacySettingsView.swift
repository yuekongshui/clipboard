import SwiftUI
import SwiftData

struct PrivacySettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @ObservedObject var viewModel: SettingsViewModel
    let settings: AppSettings

    @State private var blacklistText: String = ""

    var body: some View {
        Form {
            Toggle("启用敏感过滤（敏感文本默认不入库）", isOn: binding(\.isSensitiveFilterEnabled))

            VStack(alignment: .leading, spacing: 8) {
                Text("黑名单应用（每行一个应用名称）")
                    .font(.headline)
                TextEditor(text: $blacklistText)
                    .font(.body)
                    .frame(minHeight: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.2))
                    )
            }
        }
        .formStyle(.grouped)
        .onAppear {
            blacklistText = settings.blacklistedAppsRawValue
        }
        .onChange(of: blacklistText) { _, newValue in
            settings.blacklistedAppsRawValue = newValue
            viewModel.save(modelContext: modelContext)
        }
        .onChange(of: settings.isSensitiveFilterEnabled) { _, _ in
            viewModel.save(modelContext: modelContext)
        }
    }

    private func binding<Value>(_ keyPath: ReferenceWritableKeyPath<AppSettings, Value>) -> Binding<Value> {
        Binding(get: { settings[keyPath: keyPath] }, set: { settings[keyPath: keyPath] = $0 })
    }
}
