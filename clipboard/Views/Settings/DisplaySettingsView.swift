import SwiftUI
import SwiftData

struct DisplaySettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @ObservedObject var viewModel: SettingsViewModel
    @Bindable var settings: AppSettings

    var body: some View {
        Form {
            Picker("主题", selection: Binding(get: { settings.themeMode }, set: { settings.themeMode = $0 })) {
                Text("系统").tag(AppThemeMode.system)
                Text("浅色").tag(AppThemeMode.light)
                Text("深色").tag(AppThemeMode.dark)
                Text("自定义颜色").tag(AppThemeMode.custom)
            }

            if settings.themeMode == .custom {
                ColorPicker(
                    "自定义颜色",
                    selection: Binding(
                        get: { Color(hex: settings.customThemeColorHex) ?? .accentColor },
                        set: { settings.customThemeColorHex = $0.hexString() }
                    ),
                    supportsOpacity: false
                )
            }

            Toggle("显示图片缩略图", isOn: $settings.isImageThumbnailEnabled)
        }
        .formStyle(.grouped)
        .onChange(of: settings.isImageThumbnailEnabled) {
            viewModel.save(modelContext: modelContext)
        }
        .onChange(of: settings.themeModeRawValue) {
            viewModel.save(modelContext: modelContext)
        }
        .onChange(of: settings.customThemeColorHex) {
            viewModel.save(modelContext: modelContext)
        }
    }
}
