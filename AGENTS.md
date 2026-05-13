# Repository Guidelines

## Project Structure & Module Organization
- `Routines/` contains the iOS app source (SwiftUI views, models, services, utilities) and app assets.
- `Routines Widgets/` contains the WidgetKit extension.
- `RoutinesWatch Watch App/` contains the watchOS app; related tests live alongside.
- `RoutinesTests/`, `RoutinesUITests/`, `RoutinesWatch Watch AppTests/`, and `RoutinesWatch Watch AppUITests/` contain XCTest and UI tests.
- Assets live in `*/Assets.xcassets/`; settings resources live in `Routines/Resources/Settings.bundle/`.

## Build, Test, and Development Commands
Prefer Xcode for day-to-day work. CLI examples:
- `xcodebuild -scheme Routines -destination 'platform=iOS Simulator,name=iPhone 15' build` builds the iOS app.
- `xcodebuild -scheme Routines -destination 'platform=iOS Simulator,name=iPhone 15' test` runs the iOS test suite.
- `xcodebuild -scheme Routines -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' test` runs watchOS tests.

## Coding Style & Naming Conventions
- Swift style: 4-space indentation, SwiftUI-first patterns, and clear type/enum names (e.g., `Routine`, `StepCompletionStatus`).
- Views are in `Routines/Views/` and `RoutinesWatch Watch App/Views/` using `*View.swift` naming.
- Keep assets and settings resources organized under their respective bundles; avoid duplicating symbols across targets.
- No repository-wide formatter/linter is configured; keep changes consistent with nearby code.

## Testing Guidelines
- XCTest is used for unit and UI tests; watchOS tests are in the watch target folders.
- Name tests after behavior, e.g., `RoutineTests.swift`, `DateMigrationTests.swift`.
- Prefer targeted tests for models and utilities in `RoutinesTests/ModelTests/`.

## Commit & Pull Request Guidelines
- Commit history shows descriptive, sentence-style messages; keep the subject concise and focused on the change.
- For PRs: include a short summary, link any relevant issues, and add screenshots for UI changes (iOS and watchOS if applicable).

## Configuration Notes
- `buildServer.json` is present for tooling integration (e.g., SourceKit-LSP). Keep it updated if build settings change.

## .agents Directory

For tools that support the [.agents Protocol](https://dotagentsprotocol.com/), see the [.agents/](.agents/) directory for modular instructions, architecture memories, and skills.
