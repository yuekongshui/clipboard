import SwiftUI
import SwiftData

struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]

    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("isSettingsOpen") private var isSettingsOpen = false
    @State private var window: NSWindow?

    var body: some View {
        Group {
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
        .background(WindowAccessor(window: $window))
        .onChange(of: window) {
            if let w = window {
                w.level = .floating
                
                // 找到主窗口并绑定
                if let mainWindow = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "main" }) {
                    if mainWindow.childWindows?.contains(where: { $0 == w }) != true {
                        mainWindow.addChildWindow(w, ordered: .above)
                    }
                }
                w.makeKeyAndOrderFront(nil)
            }
        }
        .onAppear {
            isSettingsOpen = true
            // 确保主界面也被打开
            if let delegate = NSApp.delegate as? AppDelegate {
                NSApp.activate(ignoringOtherApps: true)
                if let mainWindow = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "main" }) {
                    mainWindow.makeKeyAndOrderFront(nil)
                }
            }
        }
        .onDisappear {
            isSettingsOpen = false
            if let w = window, let mainWindow = w.parent {
                mainWindow.removeChildWindow(w)
            }
        }
    }
}
