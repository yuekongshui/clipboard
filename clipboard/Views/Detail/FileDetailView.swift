import AppKit
import SwiftUI
import Quartz

struct QuickLookPreview: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> QLPreviewView {
        let view = QLPreviewView(frame: .zero, style: .normal)
        view?.autostarts = true
        view?.previewItem = url as QLPreviewItem
        return view ?? QLPreviewView()
    }

    func updateNSView(_ nsView: QLPreviewView, context: Context) {
        if nsView.previewItem?.previewItemURL != url {
            DispatchQueue.main.async {
                nsView.previewItem = url as QLPreviewItem
            }
        }
    }
}

struct FileDetailView: View {
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            meta
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Text("路径")
                    .font(.headline)
                Text(item.filePath ?? "-")
                    .textSelection(.enabled)
                    .font(.callout)

                if let path = item.filePath {
                    let exists = FileManager.default.fileExists(atPath: path)
                    HStack(spacing: 8) {
                        Text(exists ? "原文件可用" : "原文件不可用")
                            .foregroundStyle(exists ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.red))
                        Spacer()
                        if exists {
                            Button("在 Finder 中显示") {
                                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
                            }
                        }
                    }
                    
                    if exists {
                        Divider()
                            .padding(.vertical, 8)
                        Text("预览")
                            .font(.headline)
                        QuickLookPreview(url: URL(fileURLWithPath: path))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(16)
    }

    private var meta: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.fileName ?? "文件")
                .font(.title2)
            HStack(spacing: 12) {
                Text(DateFormatter.clipboardRow.string(from: item.createdAt))
                if let uti = item.fileUTI, !uti.isEmpty {
                    Text(uti)
                }
                if item.fileSize ?? 0 > 0 {
                    Text(ByteCountFormatter.string(fromByteCount: item.fileSize ?? 0, countStyle: .file))
                }
                if let source = item.sourceAppName, !source.isEmpty {
                    Text(source)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}
