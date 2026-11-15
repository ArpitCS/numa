# Numa

Numa is a native macOS browser inspired by Arc, focused on workspaces, tabs, and keyboard-first navigation.

## Current baseline

- Minimum supported macOS: 26.0
- Architecture: Apple Silicon (ARM64-only)
- UI: SwiftUI with AppKit integration where needed
- Browser engine: `WKWebView` in production, with newer SwiftUI WebKit APIs being evaluated
- Persistence: SwiftData for browser entities, SQLite with FTS5 for history/search, `UserDefaults` for preferences, and Keychain for credentials
- Dependencies: none
- Status: M1 browser core in progress
- Local Debug builds use ad-hoc signing and do not require a developer account; Release signing remains configured for later distribution work

## Feature track

This section is a high-level changelog. Keep it current as features are implemented and validated.

### Implemented

- Project and Git repository baseline
- macOS 26.0 ARM64 project configuration
- Repository instructions and generated-file ignore rules
- App composition root, window-scoped state, and `os.Logger` setup
- Unit test target with a shared smoke-test scheme
- Initial spacing and typography design tokens
- Launch UI test for the native window placeholder
- Browser engine protocol and `WKWebView` adapter
- Single-page browser view with address bar and navigation controls
- URL-versus-search routing and user-visible navigation retry state
- Same-page handling for links that request a new window
- Tab model, tab manager, and selectable tab sidebar
- Tab creation, selection, duplication, closing, and ⌘T/⌘W shortcuts
- Workspace model, workspace switching, and independent tab collections
- Workspace rename/delete controls and UserDefaults-backed workspace state

### Planned

- M1: navigation integration coverage
- M2: tab persistence and restoration
- M3: workspace interaction coverage
- M4: command bar and split view
- M5: history, bookmarks, downloads, and session restoration
- M6: profiles, private browsing, and tab lifecycle management

## Development

Build the app with:

```sh
xcodebuild -project Numa.xcodeproj -scheme Numa -configuration Debug -sdk macosx build
```

Use a dedicated branch for each feature. Keep `main` limited to reviewed, integrated changes.
