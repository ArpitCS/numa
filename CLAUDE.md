# CLAUDE.md — Native macOS Browser (Arc-inspired)

> **Status: DRAFT v0.1.** Repository baseline captured on 2026-11-15. API-availability notes remain provisional until verified against the installed SDK and official Apple documentation.
>
> **API-availability notes in this file come from training knowledge and are unverified.** Every one is tagged `[verify]`. Check against current Apple documentation and the installed SDK before relying on it, then remove the tag and record the source in §14.

---

## 0. How to Use This File

- Read this file fully at the start of every session. Re-read §1 and §11 before every task.
- This file is the PRD, architecture reference, roadmap and working agreement. Keep it current (rule 1.9).
- Keep `README.md` as the concise public-facing project summary and high-level feature changelog; update it when features or baseline decisions change.
- Project goal: a production-quality native macOS browser **and** deep understanding of Swift, SwiftUI, AppKit, WebKit and app architecture. When shipping speed conflicts with the owner's understanding, understanding wins.

## 1. Operating Rules (persistent)

1. Read CLAUDE.md before working on the project.
2. Inspect existing code before suggesting modifications. Never assume the repo is empty or that it matches this file.
3. Maintain the documented architecture (§6). Do not silently change architectural decisions; propose and get approval (log in §14).
4. Work incrementally: one small, independently understandable task at a time. Never implement the browser in one go.
5. Never implement unrelated features or "while I'm here" refactors.
6. Build after every meaningful change. Fix errors, review warnings, run relevant tests. Say what was tested and what was not.
7. Never claim a feature is complete without validating it. "Compiles" is not "works".
8. Avoid new dependencies. Any dependency needs written justification and approval.
9. Keep documentation updated in the same change that alters behaviour or architecture.
10. Always state macOS version and API availability for any Apple API introduced.
11. Explain important technical decisions and compare alternatives before choosing.
12. If the task is ambiguous, ask. Do not make major assumptions.
13. Never overwrite or delete existing project files without explicit approval.
14. Priorities, in order: correctness, maintainability, owner's learning, then speed of delivery.
15. Do not invent APIs. If unsure an API exists or what it does, say so and check docs or prototype. Never assume parity with Chromium or Arc.

## 2. Repository Snapshot

Baseline inspected on 2026-11-15 before feature development.

| Item | Value |
|---|---|
| Inspected on | 2026-11-15 |
| Repo contents (top-level tree) | `.gitignore`, `CLAUDE.md`, `README.md`, `Numa/`, `Numa.xcodeproj/` |
| Xcode project / workspace / Package.swift | `Numa.xcodeproj` with `project.xcproj` and `project.xcworkspace`; no `Package.swift` |
| Targets, schemes, bundle ID | `Numa` target and scheme; `devplaceholder.NX8RIDQU.Numa` |
| Xcode version, installed macOS SDK | Xcode 27.2 (build 27B52), macOS SDK 27.2 |
| `MACOSX_DEPLOYMENT_TARGET` (per target) | macOS 26.0 |
| Swift language mode / Swift version | Swift 5.0; default actor isolation and approachable concurrency enabled |
| Architectures (ARM64 only vs universal) | ARM64-only |
| App Sandbox + entitlements present | App Sandbox enabled; no entitlements file is currently tracked |
| Existing source files and their responsibilities | `Numa/MyApp.swift`: app entry point and window; `Numa/ContentView.swift`: initial placeholder view and preview; asset catalog contains the default accent color |
| Existing tests / test targets | None |
| Existing dependencies (SPM, etc.) | None |
| Code signing / team configured | Automatic signing; development team `U673S8NTA3`; placeholder bundle identifier |
| Does it build and run today? | `xcodebuild -project Numa.xcodeproj -scheme Numa -configuration Debug -sdk macosx CODE_SIGNING_ALLOWED=NO build` succeeds; Xcode reports one AppIntents metadata warning because the framework is not linked |
| Git state (branch, uncommitted changes) | Baseline was clean on `agents/claude-md-updates-and-git-setup`, aligned with `main`; setup changes are now being prepared |

### Baseline gaps and actionables

- The project is still the generated placeholder app, not the browser architecture described below.
- Window architecture and command-bar shortcuts remain open decisions D-005 through D-008.
- The placeholder bundle identifier must be replaced before distribution.
- A test target, logging setup, and architecture folders should be added incrementally with the relevant milestone rather than pre-created speculatively.
- Future feature work should use dedicated branches; this initial documentation and Git hygiene change belongs on `main`.

## 3. Product Vision

A premium, productivity-focused browser that treats the browser as a **workspace**, not a bag of tabs. Arc is the primary reference; we identify what makes it productive (persistent vertical sidebar, workspaces, pinned/favourite separation, command-bar-centric navigation, split view) and improve where sensible rather than copy.

Goals: first-class macOS citizen, minimal and polished UI, Apple-Silicon-optimised, strong memory management, keyboard-driven, eventually the owner's daily driver. Not a WebView wrapper: it has real tab, workspace, profile and session architecture.

Non-goals (until revisited): Chromium extension store compatibility, cross-platform support, a custom rendering engine, matching Arc feature-for-feature, any claim of being "faster than Arc" without measurements.

## 4. Product Requirements

Tiers: **MVP** (usable as a basic daily browser), **Post-MVP**, **Advanced**. Feasibility tags: ✅ achievable · 🔧 workaround needed · ⚠ significant limits · ❓ needs prototype.

### A. Browser fundamentals
| Feature | Tier | Feasibility / notes |
|---|---|---|
| Address bar, URL vs search detection | MVP | ✅ |
| Back / forward / reload / stop | MVP | ✅ |
| Loading progress | MVP | ✅ via `estimatedProgress` / `isLoading` |
| Page title | MVP | ✅ |
| Favicon | MVP | 🔧 `[verify]` no obvious public WKWebView favicon API; expect to parse `<link rel=icon>` via script or fetch `/favicon.ico`, with caching |
| Error pages (DNS, TLS, offline, cancelled) | MVP | ✅ via navigation delegate failures; custom error page |
| Context menus (link, image, page) | MVP | 🔧 customising WKWebView's menu needs AppKit hooks |
| Find in page | MVP | ✅ `[verify]` `WKWebView.find` |
| Full-screen | MVP | ✅ window full screen; HTML5 element full screen needs config `[verify]` |
| External link / `target=_blank` / popup handling | MVP | ✅ `WKUIDelegate.createWebViewWith` |
| Downloads manager | Post-MVP | ✅ `WKDownload` `[verify]` |
| History | Post-MVP | ✅ own store; WebKit does not expose a browsing-history API |
| Bookmarks | Post-MVP | ✅ |
| Default-browser registration (http/https handlers) | Post-MVP | ❓ entitlement/Info.plist requirements on macOS |
| Password manager / passkeys / Apple Pay / DRM video | Out of scope initially | ⚠ ❓ third-party WKWebView apps may be limited; prototype and document before promising |

### B. Sidebar
Persistent, collapsible vertical sidebar; favourites (compact, top), pinned tabs, regular tabs, folders/groups, drag-and-drop, active and loading indicators, close/duplicate, context menus, tab-navigation shortcuts. MVP: sidebar, regular + pinned tabs, active/loading indicators, close. Post-MVP: favourites, folders, drag-and-drop reordering, customisation. Must feel native (AppKit/SwiftUI materials, sidebar conventions), not like an embedded web app. ❓ Prototype: custom sidebar vs `NavigationSplitView`; drag-and-drop with `Transferable`/`onDrag` at scale.

### C. Workspaces ("Spaces")
Create/rename/delete/switch; per-workspace accent/theme; per-workspace pinned tabs and groups; persisted across restarts; per-workspace preferences. Advanced: per-workspace profile (see G). Names such as Personal/Work/Development/Research are examples only, never hardcoded.

### D. Tab management
MVP: multiple tabs, close, duplicate, custom ordering. Post-MVP: pinned persistence, recently closed, session restoration, tab search, groups/nesting. Advanced: automatic archiving, suspension (see §7), nested groups.

### E. Split view
Phase 1: two panes, horizontal/vertical, resizable, independent navigation, focus + keyboard routing, move tab in/out. Architecture must model a split as N panes from day one (layout tree), even though UI ships with 2. Focus and first-responder handling is the hard part; ❓ prototype.

### F. Command bar
Spotlight/Raycast-style panel (candidate shortcut ⌘T; ⌘L for address focus — decide in §14). Searches tabs, history, bookmarks, workspaces; runs commands; navigates URLs; web search; shows shortcuts. MVP: URL/search + open tabs. Later: other sources via a `CommandProvider` protocol. Latency target in §7.

### G. Profiles and privacy
Multiple profiles, private mode, permissions UI, clear data. See §8 for what is and is not isolated. Do not ship "profiles" that only change a label.

### H. Customisation
Light/dark/system, accent colours, sidebar customisation, configurable tab behaviour, custom shortcuts (where practical), per-site CSS/JS injection (Boosts-like) via `WKUserScript` / `WKUserContentController` in an appropriate `WKContentWorld` `[verify]`. Content blocking, if ever added, via `WKContentRuleList`.

### I. Extensions (Advanced milestone, not MVP)
Research targets: `WKWebExtension`, `WKWebExtensionContext`, `WKWebExtensionController`, plus the tab/window protocols the host app must implement `[verify exact names]`. Believed to require **macOS 15.4+** `[verify]`. Questions to answer by prototype: supported manifest versions, which `chrome.*`/`browser.*` APIs work, permission prompting UX, install/management flow, persistence, behaviour with our custom tab model. **Do not claim Chrome Web Store compatibility unless demonstrated with named extensions.** Record results in §14.

### J. AI (optional, modular, isolated from core)
Page summary, page Q&A, extraction, tab search, semantic history. Investigate Apple Foundation Models (believed macOS 26+ and Apple-Intelligence-capable hardware, small on-device context window `[verify all]`). Provide an `AIService` protocol; the browser core must compile and run with the AI module absent or unavailable. Handle unavailable-model states gracefully. Page text must be extracted by the browser layer and passed in; AI never touches `WKWebView` directly.

## 5. Platform Decisions

**Minimum macOS version: macOS 26.0 (D-001).** This is an owner-approved Apple-Silicon-first target. APIs introduced after macOS 26 still require availability checks.

| Capability | Believed minimum `[verify]` |
|---|---|
| `@Observable`, SwiftData, `WKWebsiteDataStore(forIdentifier:)` | macOS 14 |
| `WKWebExtension*` | macOS 15.4 |
| SwiftUI `WebView` / `WebPage` | macOS 26 |
| Foundation Models | macOS 26 + supported hardware |

The selected target is **macOS 26.0**, with APIs introduced after macOS 26 behind `if #available` and the engine protocol (§6). This keeps the deployment target aligned with the newer SwiftUI WebKit prototype while preserving an engine boundary for fallback.

Engine: **`WKWebView` hosted via `NSViewRepresentable`/AppKit is the production implementation**, behind a protocol (D-003). Evaluate newer SwiftUI `WebPage`/`WebView` APIs in a small prototype before adoption: confirm delegate/hook coverage for downloads, permissions, popups, custom context menus, interaction-state restoration and extension integration. Adopt only if it matches `WKWebView` on what we need. Record the result in §14.

Other: Apple Silicon first-class (ARM64-only, D-002). App Sandbox on; request only needed entitlements (network client, camera, mic, location, user-selected file access for downloads) and justify each.

## 6. Architecture

### 6.1 Layers and responsibilities

```
UI (SwiftUI views, AppKit bridges)      ← presentation only
  ↓ observes / sends intents
ViewModels (@Observable, @MainActor)    ← UI state + intent handling, thin
  ↓
Services / Managers (domain logic)      ← TabManager, WorkspaceManager, ProfileManager,
  ↓                                        SessionManager, DownloadManager, HistoryService...
Repositories (protocols)                ← persistence boundary
  ↓
Persistence (SwiftData / SQLite / Keychain)

Engine boundary (protocols)             ← BrowserEngine, BrowserPage: wraps WKWebView
```

- **Models**: plain value types or SwiftData `@Model` for persisted entities; no UI or WebKit types inside persisted models.
- **Views**: layout and bindings only. Never own a `WKWebView` lifecycle, never talk to persistence.
- **ViewModels**: map domain state to view state; one per screen/feature; if one grows beyond ~200 lines, split by responsibility.
- **Managers/Services**: own domain rules and state for exactly one concern (see ownership table).
- **Repositories**: `protocol` + implementation; views and ViewModels depend on the protocol; in-memory fakes for tests.
- **Protocols**: introduced only at real boundaries (engine, repositories, AI, command providers). No protocol for something with one implementation and no test or swap need.

### 6.2 State ownership

| State | Owner | Notes |
|---|---|---|
| Workspaces (list, order, theme) | `WorkspaceManager` | persisted |
| Tabs (model, order, pin/group membership) | `TabManager` | belongs to one workspace |
| Live web content (`WKWebView`) | `BrowserEngine` / `PagePool` | not owned by views; may not exist for a tab (suspended) |
| Tab runtime state (title, URL, loading, progress) | `BrowserPage` → published to `TabManager` | |
| Profiles + data stores | `ProfileManager` | |
| Window layout (sidebar, split tree, focus) | window-scoped `WindowState` | |
| Session snapshot | `SessionManager` | written via repository |
| History / bookmarks / downloads | their own services | |

Rule: **a tab is data; a web view is a disposable resource attached to a tab.** The tab model must survive its web view being destroyed.

### 6.3 Engine abstraction (sketch, not final)
`BrowserEngine` creates `BrowserPage`s for a given profile configuration. `BrowserPage` exposes: load(URL), reload, stop, goBack/goForward, current URL/title/progress/loading as observable or async-sequence state, `snapshotState() -> Data?`, `restore(from:)`, find, JS evaluation (scoped), delegate-style events (navigation, new-window, permission, download). The `WKWebView` implementation lives in one module/folder; nothing outside imports `WebKit` except that module and the AppKit hosting view. Keep the surface minimal; grow only when a feature needs it.

### 6.4 Concurrency
- UI and `WKWebView` access: `@MainActor` (WebKit objects are main-thread only).
- Persistence, favicon fetching, history indexing, file I/O: actors or background `ModelContext`/connections; never block main.
- Cross-boundary data: `Sendable` value types. No `@unchecked Sendable` without a written reason.
- Prefer structured concurrency; unstructured `Task {}` must have an owner and cancellation path.
- Check Swift 6 strict-concurrency status for the target and record it in §2.

### 6.5 Dependency injection
Constructor injection via an app-level composition root (`AppContainer`) built at launch. Environment injection for SwiftUI-visible services. **No new singletons.** `AppContainer` is not a service locator: pass only what a type needs.

### 6.6 Modularisation
Start as a single app target with clear folders (below). Extract Swift packages only when a boundary is stable and extraction brings real value (compile times, test isolation, enforced API). Candidate packages later: `BrowserEngine`, `Persistence`, `DesignSystem`. Ask before extracting.

### 6.7 Suggested folder layout (adapt to the real repo; do not restructure without approval)
```
App/            lifecycle, AppContainer, commands/menus
Engine/         BrowserEngine protocols + WebKit implementation
Features/
  Browser/ Sidebar/ Workspaces/ Tabs/ CommandBar/ SplitView/
  History/ Bookmarks/ Downloads/ Settings/
Domain/         models, managers/services
Persistence/    repositories, SwiftData/SQLite stores
DesignSystem/   tokens, reusable components
AI/             optional module
Tests/
```

## 7. Performance and Tab Lifecycle

### 7.1 Lifecycle model
| State | Web view | Meaning |
|---|---|---|
| Active | live, attached | visible tab(s) |
| Recently Active | live, detached | left within N min / last K tabs; fast switch back |
| Background | live, throttled `[verify]` | kept alive for media, calls, or pinned-live policy |
| Suspended | **none** | model + snapshot only; no process memory |
| Restoring | being created | web view created, state restoring, may show snapshot/placeholder |

Transitions, thresholds (N, K) and exemptions (audio playing, camera/mic in use, downloads, unsaved form input heuristics) are configurable constants, decided and tested in Milestone 6. Never create a live web view for every saved tab; **lazy-create on first activation.**

### 7.2 What to persist on suspend
Persist: URL, title, favicon reference, scroll/back-forward state via `WKWebView.interactionState` `[verify]` (opaque `Data`), last-active time, optional thumbnail, profile/workspace IDs.
Cannot be reliably restored: JavaScript heap and in-page app state, unsent form input, playing media position, WebSockets/live connections, some SPA state, `sessionStorage` fidelity `[verify]`, pages that required POST results. Document user-visible consequences and prefer not suspending tabs with active media/forms.

### 7.3 Things to investigate (each ends in a measurement or a note in §14)
Web view creation cost and reuse limits, process-per-web-view behaviour in WebKit `[verify]`, memory-pressure signals (`DispatchSource.makeMemoryPressureSource`), CPU of background tabs, favicon/image cache sizing, database query plans for history search, launch time, sidebar scroll/animation smoothness with hundreds of tabs.

### 7.4 Measurable goals (initial; revise from baseline measurements, never from assumptions)
Record a baseline in Instruments first, then set numbers. Starting proposals: cold launch to interactive window < 1 s; command-bar open → first result < 50 ms; tab switch (live) < 100 ms perceived; sidebar at 500 tabs holds 60 fps scrolling; suspended tab costs only model + small snapshot; history search over 100k entries < 100 ms. Tools: Instruments (Time Profiler, Allocations, Leaks, SwiftUI template), `os_signpost`, Activity Monitor for WebKit processes, XCTest `measure`. Do not claim "faster than Arc/Safari/Chrome" without a repeatable comparison methodology documented here.

## 8. Profiles and Privacy

Mechanism: one `WKWebsiteDataStore(forIdentifier:)` per persistent profile `[verify macOS 14+]`; `WKWebsiteDataStore.nonPersistent()` for private browsing. Each profile's `WKWebViewConfiguration` points to its store.

Expected to be isolated per data store `[verify each by test]`: cookies, localStorage, IndexedDB, Cache storage, service workers, HTTP cache.
**Unknown or likely shared, must be tested and documented:** HTTP auth credentials, per-site permission grants stored by our app vs by WebKit, DNS/network state, proxy settings, system-level credentials, downloads folder, our own history/bookmark stores (we decide: per profile), keychain items, cached favicons.
Private mode requirements: no history writes, no persistent cookies/storage, no session-restore entry, no thumbnails or favicon cache persisted, clear on close. State clearly what private mode does **not** hide (network observers, extensions if enabled, OS-level logging).

Permissions: camera/mic via `WKUIDelegate` media-capture decision `[verify]` plus macOS TCC and entitlements; geolocation via CoreLocation authorisation plus WebKit delegate; per-site decisions stored by us. Clear browsing data via `WKWebsiteDataStore` removal APIs with explicit data-type selection.

Security baseline: App Sandbox, hardened runtime, no `NSAllowsArbitraryLoads`, careful handling of `file://`, custom schemes, JS-bridge message handlers (validate every message, minimal surface, origin checks), no secrets in `UserDefaults`/logs, Keychain for credentials, URL display protection against spoofing.

## 9. UI / UX Design

Follow the Human Interface Guidelines. Native window behaviour (traffic lights, full screen, toolbar/titlebar integration), system materials, SF Symbols, system fonts and Dynamic Type-equivalent scaling, full keyboard navigation, VoiceOver labels, Reduce Motion / Reduce Transparency / Increase Contrast respected, light/dark/system.

References: Arc (sidebar, workspaces), Safari (macOS integration), Linear (focus, restraint), Raycast (keyboard-first command UI).
Avoid: heavy gradients, needless borders, button clutter, web-dashboard look, deep navigation, inconsistent spacing, decorative animation.

### Design tokens (initial proposal; finalise in Milestone 0, implement in `DesignSystem/`)
- **Spacing**: 4-pt grid — 4, 8, 12, 16, 24, 32.
- **Radius**: small 6, medium 10, large 14 (use continuous corners).
- **Typography**: system font; roles: title, body, secondary, caption, monospaced (for URLs where useful). No custom fonts without approval.
- **Colour**: semantic names (`surface`, `surfaceRaised`, `textPrimary`, `textSecondary`, `separator`, `accent`) mapped to system colours/asset catalog; per-workspace accent overrides `accent` only.
- **Motion**: one standard duration/curve for state changes (≈0.2 s ease), spring for drag/reorder; all animation disabled or reduced under Reduce Motion.
- **Components** (build once, reuse): `SidebarRow`, `TabRow`, `PillButton`, `IconButton`, `CommandBarRow`, `Badge/ProgressIndicator`, `SectionHeader`. A new component needs two real call sites or a clear reason.

## 10. Engineering Standards

- **Naming**: Swift API Design Guidelines; types UpperCamelCase, members lowerCamelCase, protocols named for capability (`TabStore`, `BrowserEngine`), no abbreviations beyond common ones.
- **Files**: one primary type per file, file named for it; extensions in `Type+Topic.swift`. No file without a clear responsibility.
- **Docs**: `///` on public/internal APIs with non-obvious behaviour; document threading and ownership; comments explain *why*.
- **Errors**: typed `Error` enums per domain; `throws` over optionals for failures; user-facing errors mapped at the ViewModel; never `try!`/force-unwrap in production paths.
- **Logging**: `os.Logger` with subsystem/category per module; no `print`; no URLs/PII at default level in private mode.
- **Concurrency**: see §6.4. **Memory**: no retain cycles (`[weak self]` in delegates/closures, verify with Memory Graph); every `WKWebView` teardown path removes observers, script message handlers and delegates.
- **Accessibility**: labels, hints, focus order, keyboard operability for every control; test with VoiceOver at each milestone.
- **Lint/format**: none added unless approved (dependency rule).

### Testing
- **Unit (XCTest)**: managers/services, repositories against in-memory stores, lifecycle state machine, URL/search parsing, session encode/decode. Prefer protocol fakes over mocks of Apple types.
- **Integration**: engine against a local test server or `file://` fixtures for navigation, errors, redirects, popups, downloads.
- **UI tests**: critical flows only (open tab, navigate, switch workspace, restore session).
- **Required coverage areas**: browser navigation, tab lifecycle transitions (incl. memory-pressure), workspace switching (tabs/pins isolated per workspace), session restoration (quit/relaunch, crash-like termination), profile isolation (cookie/localStorage set in profile A absent in B; private leaves nothing on disk).
- A feature is "done" only when tests exist for its logic **and** the owner has run it manually.

## 11. Learning + Development Methodology (EXTREMELY IMPORTANT)

Owner context: experienced with Swift, SwiftUI, SwiftData, MapKit/CoreLocation/EventKit and Foundation Models from iOS work, plus backend engineering. **Assume that fluency; do not re-teach it.** Spend explanation budget on what is new: AppKit and macOS windowing/responder chain, WebKit internals and delegates, browser architecture (processes, data stores, lifecycle), performance profiling, macOS distribution (signing, notarisation). Correct this paragraph if the owner says otherwise.

### 11.1 Teach before implementing (any substantial feature)
Explain: the problem → relevant Apple frameworks → chosen approach → alternatives → why this one → limitations and edge cases. Then implement.

### 11.2 Per-task procedure
1. Objective. 2. Concepts involved. 3. Files to create/modify. 4. Implementation explanation. 5. Implement **only** the agreed scope. 6. Build and test. 7. Review result. 8. What the owner should understand before moving on.

### 11.3 Do not hide complexity
Whenever a framework or API is introduced, state: what it does, why used here, key APIs, lifecycle, limitations, common mistakes. For WebKit specifically explain `WKWebView`, `WKWebViewConfiguration`, `WKNavigationDelegate`, `WKUIDelegate`, `WKWebsiteDataStore`, `WKUserContentController`, `WKDownload`, and the newer SwiftUI WebKit APIs when evaluated.

### 11.4 Avoid blind code generation
Small diffs. No hundreds of lines at once. No speculative abstractions. No replacing working code without explaining why. No major architectural change without approval. Prefer showing a minimal version first, then extending.

### 11.5 Build and validate continuously
After meaningful changes: build, fix errors, review warnings, test, report tested/untested. Never assume code compiles.

### 11.6 Learning checkpoints (end of each significant milestone)
Provide: what we built; technologies used; concepts learned; architectural decisions; what could be improved; what's next. Occasionally ask a few focused questions to verify understanding. Do not quiz every interaction.

### 11.7 Mentor stance
Act as a senior macOS engineer mentoring. Compare trade-offs; let the owner decide when reasonable options exist; push back with reasons on poor approaches and recommend better ones.

## 12. Roadmap

Iterative. Reorder or drop milestones by owner decision; advanced features are not obligations. Each milestone ends with a learning checkpoint (§11.6). Dependencies are on earlier milestones unless stated.

### M0 — Foundation
- **Objectives**: buildable project, decisions D-001..D-003 made, architecture skeleton, design tokens, basic window.
- **Scope**: fill §2; choose deployment target; composition root; `DesignSystem` tokens; empty window with native chrome; logging setup; CI-less local test setup.
- **Challenges**: deployment-target choice, sandbox entitlements, SwiftUI/AppKit window integration.
- **Acceptance**: app launches, builds with zero warnings, test target runs, §2 and §14 up to date.
- **Tests**: smoke unit test; launch UI test.
- **Learning**: macOS app lifecycle, `App` vs `NSApplicationDelegate`, entitlements, window/scene types.

### M1 — Browser Core
- **Objectives**: browse one page correctly.
- **Scope**: engine protocol + `WKWebView` implementation (and `WebPage` evaluation note), address bar, back/forward/reload/stop, progress, title, error page, `target=_blank` handling.
- **Challenges**: delegate lifecycle, KVO/observation of web-view state, URL-vs-search parsing, retain cycles.
- **Acceptance**: navigate, redirect, fail and recover on fixtures; no leaks after repeated open/close.
- **Tests**: navigation integration tests, URL parser unit tests.
- **Learning**: WebKit delegates, configuration, process model, main-actor rules.

### M2 — Tabs and Sidebar
- **Objectives**: multiple tabs in a native sidebar, persisted.
- **Scope**: tab model, `TabManager`, sidebar, pinned tabs, active/loading indicators, close/duplicate, reorder + drag-and-drop, tab persistence (SwiftData or SQLite — decide with comparison in §14), lazy web-view creation.
- **Challenges**: native sidebar feel, drag-and-drop performance, tab-vs-web-view ownership.
- **Acceptance**: tabs survive relaunch; switching creates web view lazily; reorder persists.
- **Tests**: `TabManager` unit tests, persistence round-trip, UI flow test.
- **Learning**: SwiftData modelling for this domain, SwiftUI/AppKit interop, drag/drop, `Transferable`.

### M3 — Workspaces
- **Objectives**: workspaces as first-class unit.
- **Scope**: models, switching UI + shortcuts, per-workspace tabs/pins, persistence, accent/theme.
- **Challenges**: state ownership on switch, avoiding web-view churn, animation.
- **Acceptance**: tabs/pins isolated per workspace; relaunch restores active workspace.
- **Tests**: workspace-switch unit tests, restore tests.
- **Learning**: state-ownership design, theming via environment.

### M4 — Productivity
- **Objectives**: keyboard-first workflow.
- **Scope**: command bar (`CommandProvider` protocol; tabs + URL first), shortcut system, split view (2 panes, layout-tree model), tab groups/folders, tab search.
- **Challenges**: first-responder/focus across panes and panel, global vs scoped shortcuts, floating panel windowing.
- **Acceptance**: every MVP action reachable by keyboard; split panes navigate independently and route focus correctly.
- **Tests**: command ranking unit tests, focus-routing UI tests.
- **Learning**: responder chain, `NSPanel`/overlays, `NSEvent`/menu commands.

### M5 — Browser Features
- **Scope**: history (own store, searchable), bookmarks, downloads manager, recently closed, session restoration hardening, find in page, favicon pipeline + cache.
- **Challenges**: history write volume, search performance, favicon strategy, download delegate edge cases.
- **Acceptance**: crash-like termination restores session; history search meets §7.4 goal; downloads survive relaunch policy defined.
- **Tests**: repository tests, large-dataset performance tests, download integration tests.
- **Learning**: SQLite vs SwiftData trade-offs, FTS `[verify]`, `WKDownload`.

### M6 — Advanced Browser Architecture
- **Scope**: profiles + data-store isolation, private mode, tab lifecycle states + suspension, memory-pressure handling, permissions management.
- **Challenges**: proving isolation, restoration fidelity, choosing thresholds from measurements.
- **Acceptance**: isolation test suite passes and §8 "unknown" list is resolved with evidence; memory at N suspended tabs measured against baseline.
- **Tests**: isolation, private-mode disk checks, lifecycle state machine, memory-pressure simulation.
- **Learning**: WebKit data stores, Instruments memory work, system pressure APIs.

### M7 — Extensions and Customisation
- **Scope**: WebExtensions prototype then integration (if viable), management UI, per-site CSS/JS injection.
- **Challenges**: host tab/window protocol adaptation, permissions UX, API gaps.
- **Acceptance**: a documented list of extensions that actually work, with versions tested; injection scripts isolated and removable.
- **Tests**: extension load fixtures, injection tests.
- **Learning**: WebExtension model, content worlds, script-injection security.

### M8 — Advanced Features
- **Scope**: AI module (availability-gated), CloudKit sync design + prototype, other productivity features.
- **Challenges**: model availability/limits, sync conflict model, privacy of synced browsing data.
- **Acceptance**: core runs with AI disabled; sync scoped to explicitly chosen data types.
- **Tests**: AI protocol fakes, sync conflict unit tests.
- **Learning**: Foundation Models, CloudKit.

### M9 — Production Readiness
- **Scope**: security review (§8 baseline), accessibility audit, profiling pass, test gaps, packaging, hardened runtime, code signing, notarisation, update strategy decision.
- **Acceptance**: notarised build passes Gatekeeper on a clean Mac; VoiceOver can complete core flows; documented perf results vs §7.4.
- **Tests**: full regression suite + manual checklist.
- **Learning**: distribution pipeline (Developer ID, notarytool, stapling), sandbox hardening.

## 13. Feasibility Summary (update as prototypes land)

| Class | Items |
|---|---|
| ✅ Achievable | navigation, tabs, workspaces, sidebar, split view, command bar, history/bookmarks, per-profile data stores, private mode, downloads, find, script injection |
| 🔧 Workaround | favicons, custom context menus, tab suspension fidelity, session restore edge cases |
| ⚠ Significant limits | extension compatibility vs Chromium, password manager/passkey/payments parity with Safari |
| ❓ Prototype first | WebPage/WebView adoption, WebExtensions viability, DRM video, default-browser registration, sidebar drag/drop at scale, Foundation Models for page tasks |

## 14. Decisions and Open Questions Log

Format: `ID — status — decision/question — date — evidence/source`. Status: OPEN, PROPOSED, DECIDED, REJECTED.

- D-001 — DECIDED — Minimum macOS version is macOS 26.0 — 2026-11-15 — owner decision; aligns with the current SwiftUI/WebKit evaluation target.
- D-002 — DECIDED — ARM64-only binary — 2026-11-15 — owner decision; no Intel compatibility requirement.
- D-003 — DECIDED — Use hosted `WKWebView` for production and prototype newer SwiftUI `WebPage`/`WebView` APIs behind the engine boundary — 2026-11-15 — owner decision; prototype must verify required delegate and lifecycle coverage.
- D-004 — DECIDED — Hybrid persistence: SwiftData for workspaces, tabs, bookmarks and download metadata; SQLite with FTS5 for history/search; UserDefaults for preferences; Keychain for credentials — 2026-11-15 — owner decision.
- D-005 — OPEN — Window architecture: SwiftUI `WindowGroup` + AppKit bridge vs AppKit-led shell; multi-window support timing.
- D-006 — OPEN — Command-bar shortcut conflicts (⌘T / ⌘L).
- D-007 — OPEN — Favicon retrieval strategy.
- D-008 — OPEN — Distribution: Developer ID direct vs Mac App Store (sandbox/review implications for a browser).
- Q-001 — OPEN — Which `[verify]` APIs exist at the chosen target, and do they behave as assumed? Resolve each and cite the Apple documentation page.
- Q-002 — OPEN — What exactly is and is not isolated between profiles (§8 unknown list).
- Q-003 — OPEN — Which Chrome/Firefox extensions work with WebKit WebExtensions in practice.

## 15. Source Policy

Primary sources: official Apple documentation and WWDC sessions for SwiftUI, AppKit, WebKit, SwiftData, CloudKit, Keychain, Foundation Models and API availability; the installed SDK headers are authoritative for what exists at our target. Prefer docs matching the deployment target. If a capability is uncertain, mark it ❓ and plan a prototype; do not present it as fact. Cite the source in §14 when resolving a `[verify]`.