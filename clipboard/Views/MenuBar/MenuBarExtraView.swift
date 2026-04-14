import SwiftUI
import SwiftData

struct MenuBarExtraView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    
    @Query(sort: \ClipboardItem.createdAt, order: .reverse) private var items: [ClipboardItem]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("最近记录")
                    .font(.headline)
                Spacer()
                
                Button(action: {
                    closePopover()
                    
                    // 同时打开主界面 (检查是否存在)
                    if let mainWindow = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "main" || $0.title == "Clipboard" }) {
                        mainWindow.makeKeyAndOrderFront(nil)
                    } else {
                        openWindow(id: "main")
                    }
                    
                    // 打开设置界面
                    if #available(macOS 14.0, *) {
                        openSettings()
                    } else {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    }
                    
                    NSApp.activate(ignoringOtherApps: true)
                    
                    // 确保设置窗口显示在主窗口上方
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        let windows = NSApplication.shared.windows
                        let mainWindow = windows.first(where: { $0.identifier?.rawValue == "main" || $0.title == "Clipboard" })
                        let settingsWindow = windows.first(where: { ($0.level == .normal || $0.level == .floating) && $0.identifier?.rawValue != "main" && $0.title != "Clipboard" && $0.title != "" })
                        
                        mainWindow?.makeKeyAndOrderFront(nil)
                        
                        // 确保设置窗口显示在主窗口上方
                        if let main = mainWindow, let settings = settingsWindow {
                            // 让 settingsWindow 自己去绑定，这里仅做展示保证
                            settings.makeKeyAndOrderFront(nil)
                        }
                    }
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .help("打开软件设置")
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .help("退出软件")
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(items.prefix(20)) { item in
                        MenuBarItemRow(item: item)
                        Divider()
                    }
                }
            }
            
            HStack {
                Spacer()
                Button("更多...") {
                    closePopover()
                    
                    // 检查主窗口是否已存在
                    if let mainWindow = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "main" || $0.title == "Clipboard" }) {
                        mainWindow.makeKeyAndOrderFront(nil)
                        NSApp.activate(ignoringOtherApps: true)
                    } else {
                        openWindow(id: "main")
                        NSApp.activate(ignoringOtherApps: true)
                    }
                    
                    // 确保主窗口和设置窗口（如果存在）显示在最前方
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        let windows = NSApplication.shared.windows
                        let mainWindow = windows.first(where: { $0.identifier?.rawValue == "main" || $0.title == "Clipboard" })
                        let settingsWindow = windows.first(where: { ($0.level == .normal || $0.level == .floating) && $0.identifier?.rawValue != "main" && $0.title != "Clipboard" && $0.title != "" })
                        
                        mainWindow?.makeKeyAndOrderFront(nil)
                        settingsWindow?.makeKeyAndOrderFront(nil)
                    }
                }
                .buttonStyle(.plain)
                .padding()
            }
        }
        .frame(width: 350, height: 450)
    }
    
    private func closePopover() {
        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.popover?.performClose(nil)
        }
    }
}
