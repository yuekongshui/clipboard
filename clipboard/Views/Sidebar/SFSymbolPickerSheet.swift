import SwiftUI
import AppKit

struct SFSymbolPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var symbolName: String

    @State private var keyword: String = ""

    private let columns = [GridItem(.adaptive(minimum: 56), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                TextField("搜索 SF Symbols", text: $keyword)
                    .textFieldStyle(.roundedBorder)
                Button("关闭") {
                    dismiss()
                }
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredSymbols, id: \.self) { name in
                        Button {
                            symbolName = name
                            dismiss()
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: name)
                                    .font(.system(size: 22))
                                    .frame(width: 44, height: 32)
                                Text(name)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .frame(maxWidth: 72)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(name == symbolName ? Color.accentColor.opacity(0.18) : Color.clear)
                        )
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .frame(width: 640, height: 520)
        .onAppear {
            if symbolName.isEmpty {
                symbolName = "folder"
            }
        }
    }

    private var filteredSymbols: [String] {
        let all = SFSymbolsLibrary.shared.names
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return Array(all.prefix(800))
        }
        let lower = trimmed.lowercased()
        let matches = all.filter { $0.lowercased().contains(lower) }
        return Array(matches.prefix(1200))
    }
}

