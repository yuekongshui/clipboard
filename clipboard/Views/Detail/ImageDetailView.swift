import AppKit
import SwiftUI

struct ImageDetailView: View {
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            meta
            Divider()
            if let path = item.imageLocalPath, let image = NSImage.loadFromFile(path: path) {
                ScrollView([.vertical, .horizontal]) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                }
            } else {
                ContentUnavailableView("图片不可用", systemImage: "photo", description: Text("图片文件可能已被清理或移动。"))
            }
        }
        .padding(16)
    }

    private var meta: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("图片")
                .font(.title2)
            HStack(spacing: 12) {
                Text(DateFormatter.clipboardRow.string(from: item.createdAt))
                if let w = item.imageWidth, let h = item.imageHeight {
                    Text("\(Int(w))×\(Int(h))")
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

