import Foundation
import Observation

@MainActor
@Observable
final class BrowserViewModel {
    let page: WebKitBrowserPage
    var addressText = ""

    init(engine: WebKitBrowserEngine) {
        page = engine.makePage()
    }

    func submitAddress() {
        guard let url = AddressParser.url(from: addressText) else {
            return
        }

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
}
