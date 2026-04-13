import SwiftUI
import SwiftData
import AppKit

struct ThemedContainerView<Content: View>: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]

    @State private var didBootstrap = false

    private let storageService = ClipboardStorageService.shared
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        let settings = settingsList.first
        content()
            .tint(accentColor(for: settings))
            .task {
                guard !didBootstrap else { return }
                didBootstrap = true
                storageService.bootstrapIfNeeded(modelContext: modelContext)
                updateAppearance(for: settings)
            }
            .onChange(of: settings?.themeModeRawValue) {
                updateAppearance(for: settings)
            }
            .onAppear {
                updateAppearance(for: settings)
            }
    }

    private func updateAppearance(for settings: AppSettings?) {
        guard let settings else { return }
        switch settings.themeMode {
        case .system, .custom:
            NSApp.appearance = nil
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }

    private func accentColor(for settings: AppSettings?) -> Color? {
        guard let settings, settings.themeMode == .custom else { return nil }
        return Color(hex: settings.customThemeColorHex)
    }
}

