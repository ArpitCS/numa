import Foundation

enum AddressParser {
    static func url(from input: String) -> URL? {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            return nil
        }

        if trimmedInput.contains("://") {
            return URL(string: trimmedInput)
        }

        return URL(string: "https://\(trimmedInput)")
    }
}
