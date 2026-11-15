import Foundation

enum AddressDestination: Equatable {
    case url(URL)
    case search(URL)
}

enum AddressParser {
    static func destination(from input: String) -> AddressDestination? {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            return nil
        }

        if trimmedInput.contains("://") {
            return URL(string: trimmedInput).map(AddressDestination.url)
        }

        if trimmedInput.contains(" ") {
            var components = URLComponents(string: "https://www.google.com/search")
            components?.queryItems = [URLQueryItem(name: "q", value: trimmedInput)]
            return components?.url.map(AddressDestination.search)
        }

        return URL(string: "https://\(trimmedInput)").map(AddressDestination.url)
    }
}
