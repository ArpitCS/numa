import Observation
import WebKit

@MainActor
final class WebKitBrowserEngine: BrowserEngine {
    func makePage() -> WebKitBrowserPage {
        WebKitBrowserPage()
    }
}

@MainActor
@Observable
final class WebKitBrowserPage: NSObject, BrowserPage {
    @ObservationIgnored
    let webView: WKWebView

    var url: URL?
    var title = ""
    var isLoading = false
    var estimatedProgress = 0.0
    var canGoBack = false
    var canGoForward = false

    private var observations: [NSKeyValueObservation] = []

    override init() {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()

        webView.navigationDelegate = self
        webView.uiDelegate = self
        observations = [
            webView.observe(\.url, options: [.initial, .new]) { [weak self] webView, _ in
                let url = webView.url
                Task { @MainActor [weak self] in
                    self?.url = url
                }
            },
            webView.observe(\.title, options: [.initial, .new]) { [weak self] webView, _ in
                let title = webView.title ?? ""
                Task { @MainActor [weak self] in
                    self?.title = title
                }
            },
            webView.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] webView, _ in
                let progress = webView.estimatedProgress
                Task { @MainActor [weak self] in
                    self?.estimatedProgress = progress
                }
            },
            webView.observe(\.canGoBack, options: [.initial, .new]) { [weak self] webView, _ in
                let canGoBack = webView.canGoBack
                Task { @MainActor [weak self] in
                    self?.canGoBack = canGoBack
                }
            },
            webView.observe(\.canGoForward, options: [.initial, .new]) { [weak self] webView, _ in
                let canGoForward = webView.canGoForward
                Task { @MainActor [weak self] in
                    self?.canGoForward = canGoForward
                }
            },
        ]
    }

    func load(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    func reload() {
        webView.reload()
    }

    func stopLoading() {
        webView.stopLoading()
    }

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }
}

extension WebKitBrowserPage: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        isLoading = false
    }
}
