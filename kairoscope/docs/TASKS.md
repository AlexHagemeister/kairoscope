# Kairoscope Tasks

## Workflow Reminders
- Start each session with `docs/AGENTS.md` → `docs/PRD.md` → `docs/SDD.md` (Module Quick Reference + relevant sections).
- Update this file at session start/end with progress, blockers, and next actions.
- Keep tasks scoped to the context packs in SDD Section 11; note cross-cutting work explicitly.

## [ ] Phase 1 / Milestone A — Timeline Scaffolding (Success: Tasks A1–A6 deliver a static timeline shell reachable from RootView.)
- [x] A1 Create `AppConfiguration` + feature flag plumbing (`isAuthEnabled`, API base URL placeholder). Success: Toggling `isAuthEnabled` in configuration switches between auth gate and timeline in a preview-based smoke test.
- [x] A2 Implement `AppEnvironment` dependency container (auth service stubs, timeline engines). Success: Preview/test targets resolve dependencies via `AppEnvironment` without relying on global singletons.
- [x] A3 Build `RootView` flow: auth flag check → `AuthGateView` placeholder → `TimelineShellView`. Success: With auth enabled RootView presents `AuthGateView`, with auth disabled it shows `TimelineShellView` in simulator.
- [x] A4 Scaffold `TimelineShellView` layout with title, black background, placeholder Canvas/anchor. Success: View displays required elements correctly in portrait and landscape previews.
- [x] A5 Implement `TimelineViewModel` skeleton emitting static `TimelineSnapshot` and integrate with view. Success: Bound view renders static snapshot without runtime crashes and compiles with display-link stub in place.
- [x] A6 Add SwiftUI previews + basic smoke test (`TimelineShellViewTests`) verifying title/anchor presence. Success: Preview renders and test suite confirms title and anchor visibility.

## [ ] Phase 1 / Milestone B — Gesture & Scale Engine (Success: Tasks B1–B5 unlock animated, gesture-driven timeline with visibility into performance.)
- [ ] B1 Implement `TimeScale` ladder + `TimeScaleEngine` mappings. Success: Unit tests confirm pinch deltas map to expected `TimeScale` levels.
- [ ] B2 Implement `TimelineViewport` state & drag gesture handling. Success: Drag gestures update `centerTime` proportionally in unit tests and interactive previews.
- [ ] B3 Integrate `TimelineClock` (`CADisplayLink`) and animation loop. Success: Timeline animates smoothly in simulator tied to display-link cadence.
- [ ] B4 Add unit tests for scale transitions and viewport math. Success: Tests cover edge cases (min/max scale, fast scrubs) and pass reliably in CI.
- [ ] B5 Introduce performance instrumentation hooks (OSLog metrics toggle). Success: Enabling metrics flag emits timing logs without impacting release behavior.

## [ ] Phase 1 / Milestone C — Federated Authentication (Success: Tasks C1–C5 enable Apple/Google sign-in with controllable feature flag.)
- [ ] C1 Integrate Sign in with Apple via `AuthenticationServices`. Success: Dev build completes Apple sign-in returning identity token routed through `AuthService`.
- [ ] C2 Integrate Google Sign-In via SPM package. Success: Simulator sign-in flow retrieves Google ID token and user profile data.
- [ ] C3 Implement `AuthService` protocol + mock implementation for auth-disabled mode. Success: Switching feature flag to disabled routes through mock service and bypasses external providers.
- [ ] C4 Persist sessions with `AuthSessionStore` (Keychain). Success: Valid session persists across app relaunch and exposes current user via `AuthViewModel`.
- [ ] C5 Add UI tests covering auth happy path and cancel flow. Success: XCUITests pass exercising both completion and user-cancel scenarios.

## [ ] Phase 2 / Milestone D — Entry Creation & Local Persistence (Success: Tasks D1–D5 allow users to create, store, and visualize entries locally.)
- [ ] D1 Define SwiftData models for `EventEntry`, `SpanEntry`, `MediaAssetRef`. Success: Models compile, migrate, and save/load in an in-memory store during tests.
- [ ] D2 Build `EntryCreationSheet` UX (type toggle, date pickers, text, media picker). Success: Sheet captures valid input and prevents save when required fields missing in preview.
- [ ] D3 Implement `EntryRepository` CRUD with optimistic timeline updates. Success: Creating/editing/deleting entries updates local store and reflected timeline immediately.
- [ ] D4 Render entries in timeline (events + spans). Success: Events and spans appear at correct temporal positions with distinct visuals in preview.
- [ ] D5 Add validation + unit/UI tests for entry lifecycle. Success: Automated tests cover creation, validation failures, and deletion flows.

## [ ] Phase 2 / Milestone E — Sync & Media Pipeline (Success: Tasks E1–E5 synchronize entries and media with backend services.)
- [ ] E1 Specify REST endpoints contract with backend. Success: SDD updated with confirmed endpoint specs and shared with backend team.
- [ ] E2 Implement `EntrySyncCoordinator` (pull/push + conflict handling). Success: Sync runs without crashes, resolves conflicts deterministically, and passes integration tests.
- [ ] E3 Build media upload flow (local storage, upload URL exchange, cleanup). Success: Images upload to remote storage, local cache cleans up on deletion, and flow passes manual/smoke tests.
- [ ] E4 Add background sync using `BGProcessingTaskRequest`. Success: Background task performs sync when scheduled and respects system constraints in test logs.
- [ ] E5 Implement telemetry + analytics (timeline interactions, auth events). Success: Instrumentation logs expected events when toggled on and remains silent otherwise.

## Parking Lot / Risks
- Await backend specification confirmation (SDD Section 12.1). Success: Receive backend documentation and align SDD endpoints accordingly.
- Decide on minimum iOS target (SDD Section 12.2) before committing to SwiftData. Success: Documented OS decision in SDD with approved stakeholders.
- Profile Canvas performance once animation loop exists (SDD Section 12.3). Success: Performance report captured with mitigation plan if frame rate drops below target.

## Checkpoints & Review Gates
- **Checkpoint A (after completing Tasks A1–A3):** ✅ Human review complete on 2025-09-17; proceed to A4–A6 with auth flag reset to false.
- **Checkpoint B (after completing Tasks B1–B3):** Demonstrate gesture handling and timeline animation; confirm performance metrics expectations before continuing with tests/instrumentation.
- **Checkpoint C (after completing Tasks C1–C3):** Review authentication integration end-to-end, ensuring feature flag behavior and mock service switching are correct prior to persisting sessions/tests.
- **Checkpoint D (after completing Tasks D1–D3):** Validate entry creation UX and local persistence with human feedback before rendering entries and expanding test coverage.
- **Checkpoint E (after completing Tasks E1–E3):** Confirm backend contract alignment and media sync flow with human reviewer prior to background sync/telemetry work.
- **Checkpoint R (end of any session):** Summarize changes, test status, and open questions; wait for human acknowledgment before starting new milestones.

## Session Log
- **2025-09-18 (Session 4 Update):** Refined timeline visuals (edge-to-edge axis, centered layout, labeled ticks) and removed main-actor init warnings by making `TimelineViewModel` convenience-based. Visual polish pending animation work in Milestone B.
- **2025-09-17 (Session 3 Update):** Completed Task A6 with TimelineShellView smoke tests ensuring title and anchor presence.
- **2025-09-17 (Session 3 Update):** Completed Task A5 with `TimelineViewModel` placeholder snapshot feeding TimelineShellView lifecycle hooks.
- **2025-09-17 (Session 3 Update):** Completed Task A4 with responsive timeline shell scaffold and portrait/landscape previews.
- **2025-09-17 (Session 3):** Checkpoint A cleared after verifying auth gate toggle; isAuthEnabled reset to false. Next: Task A4 timeline layout scaffolding.
- **2025-09-17 (Session 2):** Completed Tasks A1–A3 with configuration-driven RootView flow and preview coverage; awaiting human review at Checkpoint A before proceeding to A4.
- **2025-09-17:** Populated initial milestone breakdown and backlog to support AI-driven workflows; reformatted tasks with checkbox structure and success criteria.
