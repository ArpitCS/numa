import Foundation

@MainActor
protocol BrowserEngine {
    associatedtype Page: BrowserPage

    func makePage() -> Page
}

@MainActor
protocol BrowserPage: AnyObject {
    var url: URL? { get }
    var title: String { get }
    var isLoading: Bool { get }
    var estimatedProgress: Double { get }
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }

    func load(_ url: URL)
    func reload()
    func stopLoading()
    func goBack()
    func goForward()
}
