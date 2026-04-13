import SwiftUI
import AppKit

extension Color {
    init?(hex: String?) {
        guard var hexString = hex?.trimmingCharacters(in: .whitespacesAndNewlines), !hexString.isEmpty else {
            return nil
        }
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        guard hexString.count == 6 else { return nil }
        guard let value = Int(hexString, radix: 16) else { return nil }

        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }

    func hexString() -> String? {
        let nsColor = NSColor(self).usingColorSpace(.sRGB)
        guard let nsColor else { return nil }

        let r = Int(round(nsColor.redComponent * 255))
        let g = Int(round(nsColor.greenComponent * 255))
        let b = Int(round(nsColor.blueComponent * 255))

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
