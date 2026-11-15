import OSLog

@MainActor
final class AppContainer {
    let logger: Logger

    init(bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "com.arpitcs.numa") {
        logger = Logger(subsystem: bundleIdentifier, category: "app")
    }

    func makeWindowState() -> WindowState {
        WindowState()
    }

    func makeBrowserViewModel() -> BrowserViewModel {
        BrowserViewModel(engine: WebKitBrowserEngine())
    }

    func makeTabManager() -> TabManager {
        TabManager(engine: WebKitBrowserEngine())
    }

    func makeWorkspaceManager() -> WorkspaceManager {
        WorkspaceManager(engine: WebKitBrowserEngine())
    }
}
