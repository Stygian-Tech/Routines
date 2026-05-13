---
kind: agents
---

# Project Guidelines

This repository contains **Routines**, a native iOS and watchOS app for managing daily routines and tracking step completion. Built with SwiftUI, SwiftData, and CloudKit.

## Quick Reference

- **Platforms**: iOS 17+, watchOS 10+, WidgetKit extension
- **Stack**: SwiftUI, SwiftData, CloudKit
- **Targets**: `Routines/` (iOS), `RoutinesWatch Watch App/` (watchOS), `Routines Widgets/` (WidgetKit)
- **Views**: `*View.swift` naming in `Routines/Views/` and `RoutinesWatch Watch App/Views/`
- **Models**: `Routine`, `Step`, `StepCompletionStatus`, etc. in `Routines/Models/`

## Full Guidelines

See [AGENTS.md](../AGENTS.md) in the repository root for complete development guidelines:

- Project structure and module organization
- Build, test, and development commands
- Coding style and naming conventions
- Testing guidelines
- Commit and pull request guidelines
- Configuration notes (buildServer.json, SourceKit-LSP)

## Architecture

For data models, services, data flow, and day synchronization rules, see [memories/architecture.md](memories/architecture.md).
