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
                    if #available(macOS 14.0, *) {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } else {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                    NSApp.activate(ignoringOtherApps: true)
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
                    openWindow(id: "main")
                    // Bring app to front
                    NSApp.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.plain)
                .padding()
            }
        }
        .frame(width: 350, height: 450)
    }
}
