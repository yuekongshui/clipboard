import SwiftUI
import SwiftData

struct GeneralSettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @ObservedObject var viewModel: SettingsViewModel
    @Bindable var settings: AppSettings
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .system

    var body: some View {
        Form {
            Picker("语言", selection: $appLanguage) {
                Text("跟随系统").tag(AppLanguage.system)
                Text("简体中文").tag(AppLanguage.zh)
                Text("English").tag(AppLanguage.en)
                Text("日本語").tag(AppLanguage.ja)
            }
            
            Toggle("启用监听", isOn: $settings.isMonitoringEnabled)
            Toggle("启用去重", isOn: $settings.isDeduplicationEnabled)

            HStack {
                Text("最大历史记录数")
                Spacer()
                Text("\(settings.maxHistoryCount)")
                    .frame(minWidth: 60, alignment: .trailing)
                Stepper("", value: $settings.maxHistoryCount, in: 50...5000, step: 50)
                    .labelsHidden()
            }

            HStack {
                Text("自动清理天数")
                Spacer()
                Text("\(settings.autoCleanDays) 天")
                    .frame(minWidth: 80, alignment: .trailing)
                Stepper("", value: $settings.autoCleanDays, in: 1...365, step: 1)
                    .labelsHidden()
            }

            Picker("清理策略", selection: Binding(get: { settings.autoCleanStrategy }, set: { settings.autoCleanStrategy = $0; viewModel.save(modelContext: modelContext, triggerClean: true) })) {
                Text("关闭").tag(AutoCleanStrategy.none)
                Text("按条数").tag(AutoCleanStrategy.byCount)
                Text("按天数").tag(AutoCleanStrategy.byDays)
                Text("混合").tag(AutoCleanStrategy.mixed)
            }
        }
        .formStyle(.grouped)
        .onChange(of: settings.maxHistoryCount) { viewModel.save(modelContext: modelContext, triggerClean: true) }
        .onChange(of: settings.autoCleanDays) { viewModel.save(modelContext: modelContext, triggerClean: true) }
        .onChange(of: settings.isMonitoringEnabled) { viewModel.save(modelContext: modelContext) }
        .onChange(of: settings.isDeduplicationEnabled) { viewModel.save(modelContext: modelContext) }
    }
}
