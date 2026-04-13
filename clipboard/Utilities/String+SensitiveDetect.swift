import Foundation

extension String {
    func isSensitiveClipboardText() -> Bool {
        let text = trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return false }
        if text.count > 2000 { return true }

        let patterns: [String] = [
            #"(?i)\b(pass(word)?|pwd|secret|token|api[_-]?key|access[_-]?key|client[_-]?secret)\b\s*[:=]"#,
            #"(?i)\b(bearer)\s+[a-z0-9\-\._~\+\/]+=*\b"#,
            #"-----BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY-----"#,
            #"\b\d{6}\b"#,
            #"\b\d{15,19}\b"#,
            #"\b\d{17}[\dXx]\b"#
        ]

        for pattern in patterns {
            if text.range(of: pattern, options: [.regularExpression]) != nil {
                return true
            }
        }
        return false
    }
}

