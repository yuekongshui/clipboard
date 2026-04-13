import SwiftUI

struct TextDetailView: View {
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            meta
            Divider()
            ScrollView {
                Text(item.textContent ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
            }
        }
        .padding(16)
    }

    private var meta: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("文本")
                .font(.title2)
            HStack(spacing: 12) {
                Text(DateFormatter.clipboardRow.string(from: item.createdAt))
                if let source = item.sourceAppName, !source.isEmpty {
                    Text(source)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

