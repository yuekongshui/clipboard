import SwiftUI
import SwiftData

struct GeneralSettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @ObservedObject var viewModel: SettingsViewModel
    let settings: AppSettings
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .system

    var body: some View {
        Form {
            Picker("语言", selection: $appLanguage) {
                Text("跟随系统").tag(AppLanguage.system)
                Text("简体中文").tag(AppLanguage.zh)
                Text("English").tag(AppLanguage.en)
                Text("日本語").tag(AppLanguage.ja)
            }
            
            Toggle("启用监听", isOn: binding(\.isMonitoringEnabled))
            Toggle("启用去重", isOn: binding(\.isDeduplicationEnabled))

            HStack {
                Text("最大历史记录数")
                Spacer()
                Stepper(value: binding(\.maxHistoryCount), in: 50...5000, step: 50) {
                    Text("\(settings.maxHistoryCount)")
                        .frame(minWidth: 60, alignment: .trailing)
                }
                .labelsHidden()
            }

            HStack {
                Text("自动清理天数")
                Spacer()
                Stepper(value: binding(\.autoCleanDays), in: 1...365, step: 1) {
                    Text("\(settings.autoCleanDays) 天")
                        .frame(minWidth: 80, alignment: .trailing)
                }
                .labelsHidden()
            }

            Picker("清理策略", selection: Binding(get: { settings.autoCleanStrategy }, set: { settings.autoCleanStrategy = $0; viewModel.save(modelContext: modelContext) })) {
                Text("关闭").tag(AutoCleanStrategy.none)
                Text("按条数").tag(AutoCleanStrategy.byCount)
                Text("按天数").tag(AutoCleanStrategy.byDays)
                Text("混合").tag(AutoCleanStrategy.mixed)
            }
        }
        .formStyle(.grouped)
        .onChange(of: settings.maxHistoryCount) { viewModel.save(modelContext: modelContext) }
        .onChange(of: settings.autoCleanDays) { viewModel.save(modelContext: modelContext) }
        .onChange(of: settings.isMonitoringEnabled) { viewModel.save(modelContext: modelContext) }
        .onChange(of: settings.isDeduplicationEnabled) { viewModel.save(modelContext: modelContext) }
    }

    private func binding<Value>(_ keyPath: ReferenceWritableKeyPath<AppSettings, Value>) -> Binding<Value> {
        Binding(get: { settings[keyPath: keyPath] }, set: { settings[keyPath: keyPath] = $0 })
    }
}
