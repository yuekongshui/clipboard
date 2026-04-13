import SwiftUI
import SwiftData
import QuickLookUI

struct MenuBarItemRow: View {
    let item: ClipboardItem
    @Environment(\.modelContext) private var modelContext
    @State private var isHovering = false
    @State private var showPopover = false
    
    private let storageService = ClipboardStorageService.shared
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(item.previewText)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
            
            if isHovering {
                Button(action: {
                    storageService.copyItemToPasteboard(modelContext: modelContext, item: item)
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("快捷复制")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(isHovering ? Color.secondary.opacity(0.2) : Color.clear)
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if isHovering {
                        showPopover = true
                    }
                }
            } else {
                showPopover = false
            }
        }
        .onTapGesture {
            storageService.copyItemToPasteboard(modelContext: modelContext, item: item)
        }
        .popover(isPresented: $showPopover, arrowEdge: .trailing) {
            MenuBarDetailPopover(item: item)
        }
    }
    
    private var iconName: String {
        switch item.type {
        case .text: return "text.alignleft"
        case .image: return "photo"
        case .file: return "doc"
        }
    }
}

struct MenuBarDetailPopover: View {
    let item: ClipboardItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("详情预览")
                .font(.headline)
            
            Divider()
            
            switch item.type {
            case .text:
                ScrollView {
                    Text(item.textContent ?? item.previewText)
                        .font(.body)
                }
            case .image:
                if let path = item.imageLocalPath, let nsImage = NSImage.loadFromFile(path: path) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                } else {
                    Text("图片不可用")
                        .foregroundColor(.red)
                }
            case .file:
                if let path = item.filePath, FileManager.default.fileExists(atPath: path) {
                    QuickLookPreview(url: URL(fileURLWithPath: path))
                        .frame(width: 300, height: 300)
                } else {
                    Text("文件不可用或已删除")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .frame(width: 320, height: 350)
    }
}
