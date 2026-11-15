import Foundation
import Observation

@MainActor
@Observable
final class BrowserViewModel {
    let page: WebKitBrowserPage
    var addressText = ""
    var errorMessage: String?

    init(engine: WebKitBrowserEngine) {
        page = engine.makePage()
    }

    func submitAddress() {
        guard let destination = AddressParser.destination(from: addressText) else {
            return
        }

        let url: URL
        switch destination {
        case let .url(destinationURL), let .search(destinationURL):
            url = destinationURL
        }

        errorMessage = nil
        addressText = url.absoluteString
        page.load(url)
    }

    func synchronizeAddressWithPage() {
        guard let url = page.url else {
            return
        }

        addressText = url.absoluteString
    }

    func reloadOrStopLoading() {
        if page.isLoading {
            page.stopLoading()
        } else {
            page.reload()
        }
    }

    func retry() {
        errorMessage = nil
        page.reload()
    }
}
