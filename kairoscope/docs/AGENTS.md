# AGENTS.md

## Purpose

Guidance for AI agents and developers working on **Kairoscope**.  

Agents must follow this file as the contract for navigation, coding, and workflow. Your top priorities: alignment with design documents (PRD, SDD), maintaining test-suite integrity, clarity, and safety.

## Project Overview

- App name: *Kairoscope*  
- Platform: iOS — Swift + SwiftUI  
- UX defined in `docs/PRD.md` (Project Requirements Document)  
- Architecture/design specified in `docs/SDD.md` (Software Design Document)  
- Work items, sub-tasks, progress, dev notes in `docs/TASKS.md`

## Workflow & Decision Process

1. **Start every new task** by consulting `AGENTS.md`.  
2. Then review `docs/PRD.md` to ensure vision/UX alignment.  
3. Dive into `docs/SDD.md` for technical design, constraints, implementation details.  
4. Check `docs/TASKS.md` to see current stage, pending subtasks, dev notes.  

If an unanticipated design/spec issue arises (something the plan doesn’t cover), follow this divergence-flow:

- Revisit `PRD.md` to refresh end-vision.  
- Brainstorm with user (you) on proposed design change.  
- Update `SDD.md` with new technical specification.  
- Update `TASKS.md` to reflect new tasks/subtasks or modifications.  

## Setup & Command Instructions

- Required tools: Xcode version [specify minimum here], Swift version [specify], Swift Package Manager (SPM)  
- To build: `xcodebuild -scheme Kairoscope -configuration Debug`  
- To run tests: `xcodebuild test -scheme KairoscopeTests -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest'`  
- Format / lint: use `swift-format` (or whatever tool you're using) with project's style config  
- Code generation / build script steps, if any, must be declared here  

## Code Style, Comments & Conventions

- Code must follow style guidance in `docs/SDD.md`.  
- Comments must explain *why* code exists, with links to PRD or SDD when behavior is spec-driven.  
- Use tags like `IMPORTANT:`, `DO NOT MODIFY`, `MOTIVATION:` to signal nontrivial constraints.  
- Avoid force-unwraps; prefer safe optional handling.  
- UI components should have SwiftUI previews where feasible.

## Allowed & Disallowed Actions

- Allowed: modifying code under `/Sources/`, adding tests, refactoring code that is safe and well understood, modifying `docs/` when required for design/spec changes  
- Disallowed without prior consultation: large architectural rewrites, introducing new external dependencies without SDD approval, modifying third-party code, changing minimum deployment target unless justified 

## Documentation & Updates

- If you update architecture/design (SDD) or UX (PRD), mirror changes here only if they affect tooling, conventions, workflow, tests, or rules.  
- TASKS.md must always reflect current tasks; dev notes are expected but should be cleaned when resolved.  
- Review this AGENTS.md periodically (e.g. every major version or release) to remain accurate.

---