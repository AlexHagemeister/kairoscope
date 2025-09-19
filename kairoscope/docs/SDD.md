# Kairoscope – Software Design Document (SDD)

## Metadata
- **Version:** 0.1 (Draft)
- **Date:** 2025-09-17
- **Owners:** Kairoscope Core Team (initial draft by Codex agent)
- **Status:** Draft for review

## Scope
This SDD defines the technical architecture, key modules, data models, and implementation details for the Kairoscope iOS application described in `docs/PRD.md`. The document covers Phase 1 (timeline visualization + authentication) and anticipates Phase 2 (user media entries). Backend/API specifics are outlined where they impact the client, with the expectation of companion backend documentation.

## Product Requirements Traceability
| PRD Requirement | Design Element | Notes |
| --- | --- | --- |
| Continuous time stream with present anchor | `TimelineExperience` system (Sections 6.1–6.4) | Golden anchor rendered via SwiftUI `Canvas`, continuous animation driven by `TimelineClock` |
| Pinch to zoom time scale | `TimelineGestureController` + `TimeScaleEngine` | Supports ms → years via logarithmic scale ladder |
| Swipe to scrub time | `TimelineGestureController` + `TimelineViewport` | Drag gestures translate viewport while preserving current scale |
| Double-tap reset | `TimelineGestureController` | Resets viewport to "now" with spring animation |
| Seamless orientation support | Responsive layout guidelines (Section 6.5) | Uses size classes and orientation listener |
| Title at top center | `TimelineShellView` | Fixed overlay, typography per PRD |
| Sign in with Apple/Google | `AuthFeature` (Section 7) | Feature-flagged for dev; integrates with AppleAS/GoogleSignIn |
| Media entry creation | `EntryFeature` (Section 8) | Phase 2 sheet workflow with attachments |
| Entries anchored in timeline | `EntryRenderer` | Event vs span visual treatments |

## Target Platform & Dependencies
- **Minimum iOS version:** 17.0 (required for SwiftData/SwiftUI Canvas performance). Evaluate lowering to 16.x if SwiftData swapped for Core Data.
- **Language & frameworks:** Swift 5.10+, SwiftUI, Combine, Swift Concurrency (`async/await`).
- **Third-party SDKs:**
  - `AuthenticationServices` (native) for Sign in with Apple.
  - `GoogleSignIn` SDK (via Swift Package Manager) for Google authentication.
  - `swift-collections` (SPM) optional for ordered data structures (if needed).
- **Build tooling:** Xcode 16.x (specify exact version once known), Swift Package Manager.
- **Feature flags/config:** `AppConfiguration.plist` for environment toggles (auth enable/disable, API base URLs).

## Architectural Overview
Kairoscope follows a modular MVVM-inspired architecture with clearly delineated feature packages. Key layers:

1. **Presentation Layer (SwiftUI Views)**
   - `KairoscopeApp` scene composition
   - Feature shells (`TimelineShellView`, `EntryCreationSheet`, `AuthGateView`)

2. **State & View Models**
   - `TimelineViewModel` orchestrates viewport state, scale, and rendered timeline items.
   - `AuthViewModel` manages authentication session state.
   - `EntryViewModel` handles entry creation/edit flows.

3. **Domain Services**
   - `TimeScaleEngine`, `TimelineClock`, `TimelineGeometry` for temporal calculations.
   - `EntryRepository`, `EntrySyncCoordinator` for data persistence + sync.
   - `AuthService` abstraction for federated sign-in providers.

4. **Data Layer**
   - Local store via SwiftData (backed by SQLite) for offline-first entry storage.
   - Remote REST API (`Kairoscope Cloud`) for auth token exchange, entry sync, media upload.

```
+---------------------------+         +-----------------------+
| Presentation (SwiftUI)    |<------->| View Models (ObservableObject)
+---------------------------+         +-----------------------+
                 |                               |
                 v                               v
        +----------------+              +--------------------+
        | Domain Engines |<------------>| Repositories/Sync  |
        +----------------+              +--------------------+
                                                |
                                                v
                                   +------------------------+
                                   | Local Store / Network  |
                                   +------------------------+
```

## Application Lifecycle & Composition
- `KairoscopeApp` loads `AppConfiguration` then instantiates `AppEnvironment` singleton providing dependency container (auth, repositories, feature flags).
- On launch, app presents `RootView`:
  1. Checks feature flag `isAuthEnabled`.
  2. If enabled and no session → show `AuthGateView`.
  3. On successful authentication → show `TimelineShellView`.
  4. Entry creation sheet is presented modally on demand.
- Orientation changes handled via `@Environment(\.verticalSizeClass)` and `UIDeviceOrientationDidChange` publisher. Layout uses `TimelineLayoutModel` to adjust paddings, tick density, and typography.

## Timeline Experience
### 6.1 Rendering Strategy
- **Canvas-based drawing:** Use `Canvas` for performant tick rendering with custom `TimelineRenderer` drawing ticks, labels, and anchor per frame.
- **Display Link:** `TimelineClock` wraps `CADisplayLink` to push frame timestamps into `TimelineViewModel` for smooth movement. Movement speed derived from current scale (pixels per second).
- **Present anchor:** Rendered as concentric circles with radial gradient (gold). Maintains absolute X = center of viewport.

### 6.2 Time Scale & Viewport
- `TimeScale` represents logical zoom level with properties:
  - `unitsPerPoint` (Temporal duration per logical point).
  - `majorTickInterval`, `minorTickInterval`.
  - `labelFormatter` closure.
- Ladder defined as struct array ranging microseconds → decades using logarithmic spacing.
- `TimeScaleEngine` maps pinch delta to nearest valid `TimeScale` while preserving focus time (center). Uses exponential smoothing to avoid jumps.
- `TimelineViewport` tracks `centerTime` (Date) and `visibleDuration`. Drag gestures adjust `centerTime` by translation * `unitsPerPoint`.

### 6.3 Gestures
- `TimelineGestureController` composes gestures:
  - `MagnificationGesture` updates scale via `TimeScaleEngine`.
  - `DragGesture(minimumDistance: 1)` updates viewport center.
  - `TapGesture(count: 2)` triggers animated reset to `Date.now`.
- Gesture state stored in `TimelineViewModel`, using `@MainActor` to keep UI thread safe.
- Haptics: provide `UIImpactFeedbackGenerator` on double-tap reset.

### 6.4 Labels & Tick Density
- `TimelineRenderer` computes visible tick marks by sampling precomputed tick templates per `TimeScale`.
- Uses `AttributedString` for labels with monospaced digits where applicable.
- Collision avoidance: skip labels if bounding boxes intersect previous label (tracked per frame).
- For extremely zoomed-out scales, degrade gracefully to aggregated markers (e.g., months/years) with bigger typography.

### 6.5 Orientation & Responsiveness
- Layout uses `GeometryReader` to compute viewport width/height.
- In landscape, top title shrinks to `TitleStyle.compact` (smaller font). In portrait uses `TitleStyle.regular`.
- Anchor circle size computed relative to min(width, height).
- Supports Dynamic Type by scaling fonts but clamps to maintain readability.

### 6.6 Performance Considerations
- Canvas drawing limited to 120 FPS by DisplayLink but uses `TimelineRenderCache` to memoize tick paths per scale.
- Use `Metal` fallback if Canvas profiling indicates jank (Phase 2 improvement).
- Heavy computations offloaded to background Task via `Task.detached` but publish results on main actor.

## Authentication Feature
- **Overview:** Provide federated sign-in with Apple & Google, with dev toggle `isAuthEnabled`.

### 7.1 Flow
1. App reads `AuthSessionStore` for cached credentials.
2. If invalid/absent and flag enabled, show `AuthGateView` with two buttons.
3. On Apple sign-in:
   - Use `ASAuthorizationController` to request `fullName`, `email` (only first login).
   - Receive identity token → pass to backend `/auth/apple` for session exchange.
4. On Google sign-in:
   - Use `GIDSignIn` with client ID (from Google Cloud console).
   - Obtain ID token → exchange at backend `/auth/google`.
5. Backend returns Kairoscope session (JWT + refresh token) stored securely in Keychain.
6. `AuthService` exposes `currentUser` using `@Published` to drive UI.

### 7.2 Components
- `AuthViewModel`: handles UI state (loading, error), publishes `AuthPhase`.
- `AuthService`: protocol with implementations `AppleAuthService`, `GoogleAuthService`, `MockAuthService` (for auth-disabled mode).
- `AuthSessionStore`: Keychain wrapper for secure token storage.
- `AppConfiguration.isAuthEnabled`: toggled via build settings/plist for dev/testing.

### 7.3 Error Handling
- Map auth errors to user-friendly messages (e.g., `SignInError.canceled`, `.failed`).
- Provide retry button.
- Log errors via `TelemetryClient` (Phase 2 instrumentation).

## Entry Feature (Phase 2)
### 8.1 Data Model
- `TimeEntry` (protocol / base model)
  - `id: UUID`
  - `createdAt: Date`
  - `updatedAt: Date`
  - `ownerUserID: String`
  - `title: String?`
  - `note: String?`
  - `mediaAssets: [MediaAssetRef]`
- `EventEntry: TimeEntry`
  - `moment: Date`
- `SpanEntry: TimeEntry`
  - `start: Date`
  - `end: Date`
- `MediaAssetRef`
  - `id: UUID`
  - `type: .image`
  - `localURL: URL?`
  - `remoteURL: URL?`
  - `thumbnailURL: URL?`

### 8.2 Persistence
- Local: SwiftData models mirroring above. Images stored in app-specific directory (`FileManager.default.urls(for: .documentDirectory)`), thumbnails generated via `ImageRenderer`.
- Remote: `EntrySyncCoordinator` diffs local store vs server, pushes via REST:
  - `GET /entries` (sync down)
  - `POST /entries` (create)
  - `PATCH /entries/{id}` (update)
  - `DELETE /entries/{id}` (delete)
  - `POST /media` (returns upload URL)
- Sync triggered on:
  - App launch (post-auth)
  - Pull-to-refresh (future)
  - Background refresh tasks (BGProcessingTaskRequest) when permitted.

### 8.3 UI & Interaction
- Entry creation triggers:
  1. Floating `+` button (bottom-right) using `ZStack` overlay on timeline.
  2. Long press on timeline: `LongPressGesture` produces context menu/entry sheet prefilled with touched time.
- `EntryCreationSheet` (SwiftUI sheet) composed of `Form` sections:
  - Entry type segmented control (Event/Span).
  - Date pickers (`DatePicker` / range).
  - Title & note fields (multiline TextEditor).
  - Media picker using `PhotosPicker` (requires `NSPhotoLibraryUsageDescription`).
- Validation ensures `span.end >= span.start`, media size < defined limit (e.g., 10 MB).
- On save: updates local store, triggers optimistic update in `TimelineViewModel` with animation.

### 8.4 Rendering Entries
- `EntryRenderer` overlays entry markers on timeline Canvas.
- Events: vertical glow line + circular glyph.
- Spans: translucent bar spanning start/end positions.
- Collision resolution for overlapping entries using Z-index and offset stacking.

## Data & Configuration Layer
- `AppEnvironment` holds shared dependencies via factories for simplified previews/testing.
- `AppConfiguration` loads from `AppConfiguration.plist` with overrides from environment variables for CI.
- `NetworkClient` using `URLSession` with Combine publisher adapters & async APIs.
- `TelemetryClient` (Phase 2) for analytics/diagnostics (e.g., OSLog, custom backend).

## Error Handling & Logging
- Centralize error types in `KairoscopeError` enum.
- Use `Logger` (OSLog) categories: `.timeline`, `.auth`, `.sync`.
- Non-fatal issues surfaced via subtle toasts/snackbars (if introduced) or `Alert` modals.

## Accessibility & Localization
- Ensure Dynamic Type support for labels; scale timeline fonts with `FontMetrics` but clamp min/max.
- VoiceOver: Provide accessible descriptions for anchor, timeline position (“Present”, “Jan 24, 2024 3 PM”). Consider custom rotor for time scale (Phase 2+).
- Colors meet contrast (Gold #FFD700 on Black #000000). Provide high-contrast alternative if users enable `Increase Contrast` (swap to white?).
- Localization: Start with English; structure strings via `Localizable.strings`. Timeline label formatters use locale-specific date symbols.

## Testing Strategy
- **Unit Tests:**
  - `TimeScaleEngineTests` verifying zoom transitions, units per point.
  - `TimelineGeometryTests` ensuring tick generation matches expected intervals.
  - `AuthServiceTests` with mocked Apple/Google responses.
  - `EntryRepositoryTests` using in-memory SwiftData container.
- **Snapshot/UI Tests:** Leverage `XCTest` + `ViewInspector` or `SwiftSnapshotTesting` for timeline states across scales/orientations.
- **Integration Tests:** UI tests (`XCUITest`) covering gesture flows (pinch/drag), auth happy path, entry creation.
- **Performance Tests:** Measure frame rendering time across scales with Instruments (metal, time profiler).
- **Continuous Integration:** Set up GitHub Actions (or Xcode Cloud) running `xcodebuild test -scheme KairoscopeTests` on PRs.

## Security & Privacy
- Store auth tokens in Keychain (`kSecAttrAccessibleAfterFirstUnlock`).
- Media stored locally in app sandbox; remove files on entry deletion.
- Use HTTPS with certificate pinning (Phase 2) for backend requests.
- Respect user privacy: avoid collecting PII beyond what auth requires.

## Deployment & Releases
- Use SPM for dependency management.
- Build configurations: `Debug`, `Release`, `Staging` (for QA with staging backend).
- Feature flag `isAuthEnabled` defaults to true in Release, false in Debug (override via scheme environment variable).

## Module Quick Reference
| Component | Section | Purpose | Key Inputs / Outputs |
| --- | --- | --- | --- |
| `KairoscopeApp` | Section 5 | Bootstraps dependencies and decides between auth gate and timeline | Reads `AppConfiguration`, injects `AppEnvironment`, presents `RootView` |
| `TimelineShellView` | Sections 5, 6 | Composes title, timeline canvas, gesture overlays | Consumes `TimelineViewModel` state, emits gesture intents |
| `TimelineViewModel` | Sections 5, 6 | Coordinates viewport state, scale, render pipeline | Receives tick calculations from `TimeScaleEngine`, publishes `TimelineSnapshot` to views |
| `TimeScaleEngine` & `TimelineGeometry` | Section 6.2 / 6.4 | Convert gesture deltas into temporal scales and tick layouts | Inputs: pinch magnitude, viewport size; Outputs: `TimeScale`, tick positions |
| `TimelineClock` | Section 6.1 | Drives animation frames | Wraps `CADisplayLink`, publishes frame timestamps |
| `AuthFeature` (`AuthViewModel`, `AuthService`) | Section 7 | Handles federated auth and session persistence | Inputs: Apple/Google tokens, Config flag; Outputs: `AuthPhase`, Keychain session |
| `EntryFeature` (`EntryViewModel`, `EntryRepository`) | Section 8 | Manages entry CRUD and sync | Inputs: user actions, local store; Outputs: timeline-ready entry models |
| `EntryRenderer` | Section 8.4 | Renders entry glyphs on timeline canvas | Inputs: entries, viewport; Outputs: drawing commands |
| `AppEnvironment` & `NetworkClient` | Section 9 | Dependency container and network abstraction | Provides shared services to view models and repositories |

## AI-Driven Development Workflow
### 11.1 Session Bootstrap
- Load `docs/AGENTS.md` → `docs/PRD.md` → this SDD (focus on Module Quick Reference + relevant sections) before coding.
- Open `docs/TASKS.md` to confirm active work items; append new subtasks or progress updates at session start/end.
- Assume no persistent memory: each session rehydrates state exclusively from documentation and repository code.

### 11.2 Context Packs for Common Tasks
- **Timeline Feature Work:** Read Sections 5–6 and the Module Quick Reference rows for `TimelineShellView`, `TimelineViewModel`, `TimeScaleEngine`.
- **Authentication Work:** Read Section 7 and relevant entries in Module Quick Reference; reference `AppConfiguration` details.
- **Entry Feature Work:** Combine Section 8 with data-layer notes in Section 9.
- Keep responses and pull requests scoped to one context pack whenever possible to avoid context window bloat.

### 11.3 Incremental Work Packages
1. **Phase 1 / Milestone A:** Scaffold `KairoscopeApp`, `TimelineShellView`, and placeholder `TimelineViewModel` (Sections 5–6).
2. **Phase 1 / Milestone B:** Implement gesture handling + `TimeScaleEngine` with unit tests (Sections 6.2–6.4, Section 10).
3. **Phase 1 / Milestone C:** Integrate Sign in with Apple/Google behind feature flag (Section 7).
4. **Phase 2 / Milestone D:** Build entry creation UI + local persistence (Section 8.3).
5. **Phase 2 / Milestone E:** Complete sync + media upload pipeline (Sections 8.2, 9).
- Each work package should conclude by updating `docs/TASKS.md` with status, logging key decisions in this SDD if architecture changes.

### 11.4 Handoff & Documentation Discipline
- Record deviations or clarifications directly in relevant SDD sections; avoid relying on conversational history.
- Before ending a coding session, ensure:
  - Tests covering new logic are either added or listed as TODO in `docs/TASKS.md`.
  - Pending risks or blockers are captured in Section 12 (Open Questions & Risks) or `docs/TASKS.md`.
- When shrinking context, reference module names and section numbers from the Module Quick Reference to orient the next agent quickly.

## Phase Roadmap Alignment
- **Phase 1:**
  - Implement timeline visualization (Sections 6.1–6.5).
  - Add Title overlay.
  - Integrate gesture handling.
  - Implement auth shell with feature flag.
  - Establish local storage scaffolding (even if entries not yet exposed).
- **Phase 2:**
  - Entry creation UI + persistence + rendering.
  - Media support & upload pipeline.
  - Telemetry & analytics improvements.
  - Additional accessibility enhancements.

## Open Questions & Risks
1. **Backend ownership:** Need confirmation on backend tech stack and endpoints. This SDD assumes REST service; update once backend spec exists.
2. **Minimum OS support:** If iOS 16 support is mandatory, revisit SwiftData choice (fallback to Core Data).
3. **Animation performance:** If Canvas + DisplayLink insufficient, consider Metal-based renderer.
4. **Auth flag scope:** Determine if per-build or runtime remote config is preferred.
5. **Media storage limits:** Define quotas and compression policy for images.

---
