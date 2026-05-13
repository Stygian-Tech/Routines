---
id: arch_routines
title: Routines Architecture
importance: high
tags: swiftdata, cloudkit, architecture
---

# Routines Architecture

## Data Models

- **Routine**: Main model with name, time, icon, color, days, and steps
- **Step**: Individual steps within a routine with name, order, status, and scheduled days

## Key Services

- **RoutineManager**: Manages routine operations (creation, deletion, completion checking)
- **StepManager**: Handles step operations
- **RoutineDaySynchronizer**: Ensures day consistency between routines and steps
- **CloudKitSyncObserver**: Monitors CloudKit sync status
- **CloudKitSubscriptionManager**: Manages CloudKit push notifications
- **CloudKitNotificationManager**: Handles CloudKit notification processing

## Data Flow

1. User creates/edits routines and steps in SwiftUI views
2. Changes are persisted to SwiftData ModelContext
3. SwiftData automatically syncs to CloudKit
4. CloudKit syncs changes to other devices
5. CloudKitSyncObserver notifies the app of remote changes
6. Views update automatically via SwiftData @Query

## Day Synchronization

- Routine days are always the superset of all step days
- Adding a day to a step automatically adds it to the parent routine
- Removing a day from a routine cascades to all steps (unless it would orphan a step)
- Steps cannot be left without any scheduled days

## CloudKit Sync

- Both iOS and watchOS apps use the same CloudKit container
- Automatic migration from local-only storage to CloudKit
- Real-time sync with push notifications
- Handles conflicts gracefully

## Completion Tracking

- Routines track completion status: incomplete, complete, or complete with skipped steps
- Steps can be marked as complete, incomplete, or skipped
- Completion status is calculated automatically based on step statuses
- Only steps scheduled for today are considered in completion calculations
