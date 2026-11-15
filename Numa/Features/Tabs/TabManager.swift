import Observation

@MainActor
@Observable
final class TabManager {
    private let engine: WebKitBrowserEngine

    private(set) var tabs: [BrowserTab] = []
    var selectedTabID: BrowserTab.ID?

    init(engine: WebKitBrowserEngine) {
        self.engine = engine
        newTab()
    }

    var selectedTab: BrowserTab? {
        guard let selectedTabID else {
            return nil
        }
        return tabs.first { $0.id == selectedTabID }
    }

    @discardableResult
    func newTab(select: Bool = true) -> BrowserTab {
        let tab = BrowserTab(viewModel: BrowserViewModel(engine: engine))
        tabs.append(tab)
        if select || selectedTabID == nil {
            selectedTabID = tab.id
        }
        return tab
    }

    func selectTab(_ id: BrowserTab.ID) {
        guard tabs.contains(where: { $0.id == id }) else {
            return
        }
        selectedTabID = id
    }

    func closeTab(_ id: BrowserTab.ID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else {
            return
        }

        let wasSelected = selectedTabID == id
        tabs.remove(at: index)

        if tabs.isEmpty {
            newTab()
        } else if wasSelected {
            selectedTabID = tabs[min(index, tabs.count - 1)].id
        }
    }

    @discardableResult
    func duplicateTab(_ id: BrowserTab.ID) -> BrowserTab? {
        guard let tab = tabs.first(where: { $0.id == id }) else {
            return nil
        }

        let duplicate = newTab(select: false)
        duplicate.viewModel.addressText = tab.viewModel.addressText
        if let url = tab.viewModel.page.url {
            duplicate.viewModel.page.load(url)
        }
        return duplicate
    }
}
