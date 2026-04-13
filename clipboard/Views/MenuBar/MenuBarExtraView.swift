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
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: "gearshape")
                        .help("打开系统设置")
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    openSettings()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .help("打开软件设置")
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding()
            
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(items.prefix(10)) { item in
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
