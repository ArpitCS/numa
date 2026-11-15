import OSLog
import SwiftUI

struct ContentView: View {
    private let container: AppContainer
    @State private var windowState: WindowState
    @State private var tabManager: TabManager

    init(container: AppContainer) {
        self.container = container
        _windowState = State(initialValue: container.makeWindowState())
        _tabManager = State(initialValue: container.makeTabManager())
    }

    var body: some View {
        @Bindable var tabManager = tabManager

        NavigationSplitView(columnVisibility: $windowState.sidebarVisibility) {
            TabSidebar(tabManager: tabManager)
        } detail: {
            if let selectedTab = tabManager.selectedTab {
                BrowserView(viewModel: selectedTab.viewModel)
            }
        }
        .onAppear {
            container.logger.info("Main window appeared")
        }
    }
}

private struct TabSidebar: View {
    @Bindable var tabManager: TabManager

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tabs")
                    .font(NumaTypography.windowTitle)
                Spacer()
                Button {
                    tabManager.newTab()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Tab")
                .keyboardShortcut("t", modifiers: .command)

                Button {
                    if let selectedTabID = tabManager.selectedTabID {
                        tabManager.closeTab(selectedTabID)
                    }
                } label: {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel("Close Tab")
                .keyboardShortcut("w", modifiers: .command)
            }
            .padding(.horizontal, NumaSpacing.medium)
            .padding(.vertical, NumaSpacing.small)

            List(selection: $tabManager.selectedTabID) {
                ForEach(Array(tabManager.tabs.enumerated()), id: \.element.id) { index, tab in
                    HStack(spacing: NumaSpacing.small) {
                        if let shortcut = TabShortcut.character(for: index) {
                            tabSelectionButton(tab, index: index)
                                .keyboardShortcut(KeyEquivalent(shortcut), modifiers: .command)
                        } else {
                            tabSelectionButton(tab, index: index)
                        }
                        Button {
                            tabManager.closeTab(tab.id)
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Close \(tab.title)")
                    }
                    .tag(tab.id)
                    .contextMenu {
                        Button("Duplicate Tab") {
                            tabManager.duplicateTab(tab.id)
                        }
                        Button("Close Tab", role: .destructive) {
                            tabManager.closeTab(tab.id)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .navigationTitle("Numa")
    }

    private func tabSelectionButton(_ tab: BrowserTab, index: Int) -> some View {
        Button {
            tabManager.selectTab(tab.id)
        } label: {
            HStack(spacing: NumaSpacing.small) {
                if tab.isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "globe")
                        .foregroundStyle(.secondary)
                }

                Text(tab.title)
                    .lineLimit(1)

                Spacer()
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("tab-\(index + 1)")
    }
}

#Preview {
    ContentView(container: AppContainer())
}
