import OSLog
import SwiftUI

struct ContentView: View {
    private let container: AppContainer
    @State private var windowState: WindowState
    @State private var workspaceManager: WorkspaceManager

    init(container: AppContainer) {
        self.container = container
        _windowState = State(initialValue: container.makeWindowState())
        _workspaceManager = State(initialValue: container.makeWorkspaceManager())
    }

    var body: some View {
        @Bindable var workspaceManager = workspaceManager

        NavigationSplitView(columnVisibility: $windowState.sidebarVisibility) {
            WorkspaceSidebar(workspaceManager: workspaceManager)
        } detail: {
            if let selectedTab = workspaceManager.selectedWorkspace?.tabManager.selectedTab {
                BrowserView(viewModel: selectedTab.viewModel)
            }
        }
        .onAppear {
            container.logger.info("Main window appeared")
        }
    }
}

private struct WorkspaceSidebar: View {
    let workspaceManager: WorkspaceManager
    @State private var renameDraft = ""
    @State private var isRenaming = false
    @State private var isConfirmingDeletion = false

    var body: some View {
        @Bindable var workspaceManager = workspaceManager

        VStack(spacing: 0) {
            HStack {
                Text("Workspaces")
                    .font(NumaTypography.windowTitle)
                if let selectedWorkspace = workspaceManager.selectedWorkspace {
                    Text(selectedWorkspace.name)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("selectedWorkspaceName")
                }
                Spacer()
                Button {
                    workspaceManager.createWorkspace(named: "Workspace \(workspaceManager.workspaces.count + 1)")
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Workspace")

                Button {
                    renameDraft = workspaceManager.selectedWorkspace?.name ?? ""
                    isRenaming = true
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel("Rename Workspace")

                Button {
                    isConfirmingDeletion = true
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(workspaceManager.workspaces.count == 1)
                .accessibilityLabel("Delete Workspace")
            }
            .padding(.horizontal, NumaSpacing.medium)
            .padding(.top, NumaSpacing.small)

            Picker("Workspace", selection: $workspaceManager.selectedWorkspaceID) {
                ForEach(workspaceManager.workspaces) { workspace in
                    Text(workspace.name).tag(workspace.id)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, NumaSpacing.medium)
            .padding(.vertical, NumaSpacing.small)
            .accessibilityIdentifier("workspacePicker")

            if let selectedWorkspace = workspaceManager.selectedWorkspace {
                TabSidebar(tabManager: selectedWorkspace.tabManager)
            }
        }
        .navigationTitle("Numa")
        .alert("Rename Workspace", isPresented: $isRenaming) {
            TextField("Workspace name", text: $renameDraft)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                guard let id = workspaceManager.selectedWorkspaceID as UUID? else {
                    return
                }
                _ = workspaceManager.renameWorkspace(id, to: renameDraft)
            }
        }
        .confirmationDialog(
            "Delete this workspace?",
            isPresented: $isConfirmingDeletion,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let id = workspaceManager.selectedWorkspaceID as UUID? {
                    _ = workspaceManager.deleteWorkspace(id)
                }
            }
            Button("Cancel", role: .cancel) {}
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
        .navigationTitle("Tabs")
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
