import AppKit
import SwiftUI

struct ClipboardRowView: View {
    let item: ClipboardItem

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            leading
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text(DateFormatter.clipboardRow.string(from: item.createdAt))
                    if let source = item.sourceAppName, !source.isEmpty {
                        Text(source)
                    }
                    Text(item.category?.name ?? "未分类")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            Spacer()

            if item.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var leading: some View {
        switch item.type {
        case .text:
            Image(systemName: "text.alignleft")
                .font(.system(size: 18))
        case .image:
            Image(systemName: "photo")
                .font(.system(size: 18))
        case .file:
            Image(systemName: "doc")
                .font(.system(size: 18))
        }
    }
}
