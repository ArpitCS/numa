import Observation
import SwiftUI

@MainActor
@Observable
final class WindowState {
    var sidebarVisibility: NavigationSplitViewVisibility = .all
    var selectedWorkspaceID: UUID?
}
