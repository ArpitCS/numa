import OSLog
import SwiftUI

struct ContentView: View {
    private let container: AppContainer
    @State private var windowState: WindowState

    init(container: AppContainer) {
        self.container = container
        _windowState = State(initialValue: container.makeWindowState())
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $windowState.sidebarVisibility) {
            Text("Sidebar")
                .navigationTitle("Numa")
        } detail: {
            Text("New Tab")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            container.logger.info("Main window appeared")
        }
    }
}

#Preview {
    ContentView(container: AppContainer())
}
