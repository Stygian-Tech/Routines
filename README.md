# Routines

A native iOS and watchOS app for managing your daily routines and tracking step completion. Built with SwiftUI and SwiftData, with seamless CloudKit synchronization across all your Apple devices.

## Features

### Core Functionality
- **Routine Management**: Create custom routines with names, scheduled times, icons, and colors
- **Step Tracking**: Add multiple steps to each routine and track completion status
- **Day Scheduling**: Schedule routines and individual steps for specific days of the week
- **Completion Status**: Track routines and steps as complete, incomplete, or skipped
- **Smart Day Synchronization**: Automatic synchronization between routine days and step days ensures consistency

### Platform Support
- **iOS**: Full-featured app with beautiful SwiftUI interface
- **watchOS**: Companion app for quick routine access and step completion on Apple Watch
- **Widgets**: iOS 18+ Control Widget support for quick app access

### Sync & Data
- **CloudKit Integration**: Automatic synchronization across all devices using iCloud
- **SwiftData**: Modern data persistence with automatic CloudKit sync
- **Real-time Updates**: Push notifications for CloudKit changes

### User Experience
- **Customizable App Icons**: Choose from multiple app icon options
- **Locale Support**: Respects system locale settings for day names and week start
- **Accessibility**: Full VoiceOver support and accessibility labels
- **Tips**: Built-in TipKit integration for onboarding

## Requirements

- iOS 17.0+ / watchOS 10.0+
- Xcode 15.0+
- Swift 5.9+
- Active Apple Developer account (for CloudKit)

## Project Structure

```
Routines/
├── Routines/                          # iOS app source
│   ├── App/                           # App entry point and configuration
│   ├── Models/                        # SwiftData models (Routine, Step, etc.)
│   ├── Views/                         # SwiftUI views and components
│   ├── Services/                      # Business logic and CloudKit services
│   ├── Utilities/                     # Helper utilities
│   └── Assets.xcassets/               # App icons and images
├── Routines Widgets/                  # WidgetKit extension
├── RoutinesWatch Watch App/           # watchOS app
├── RoutinesTests/                     # iOS unit tests
├── RoutinesUITests/                   # iOS UI tests
├── RoutinesWatch Watch AppTests/      # watchOS unit tests
└── RoutinesWatch Watch AppUITests/    # watchOS UI tests
```

## Getting Started

### Prerequisites

1. **Xcode**: Install Xcode 15.0 or later from the Mac App Store
2. **Apple Developer Account**: Sign in with your Apple Developer account in Xcode
3. **CloudKit Setup**: Ensure CloudKit is enabled in your Apple Developer account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Stygian-Tech/Routines.git
cd Routines
```

2. Open the project in Xcode:
```bash
open Routines.xcodeproj
```

3. Configure CloudKit:
   - Select the project in Xcode
   - Go to the "Signing & Capabilities" tab for each target
   - Ensure CloudKit is enabled and configured with the same iCloud container for iOS and watchOS apps

4. Build and run:
   - Select your target device or simulator
   - Press `Cmd+R` to build and run

### Building from Command Line

```bash
# Build iOS app
xcodebuild -scheme Routines -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run iOS tests
xcodebuild -scheme Routines -destination 'platform=iOS Simulator,name=iPhone 15' test

# Run watchOS tests
xcodebuild -scheme Routines -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' test
```

## Architecture

### Data Models

- **Routine**: Main model representing a routine with name, time, icon, color, days, and steps
- **Step**: Individual steps within a routine with name, order, status, and scheduled days

### Key Services

- **RoutineManager**: Manages routine operations (creation, deletion, completion checking)
- **StepManager**: Handles step operations
- **RoutineDaySynchronizer**: Ensures day consistency between routines and steps
- **CloudKitSyncObserver**: Monitors CloudKit sync status
- **CloudKitSubscriptionManager**: Manages CloudKit push notifications
- **CloudKitNotificationManager**: Handles CloudKit notification processing

### Data Flow

1. User creates/edits routines and steps in SwiftUI views
2. Changes are persisted to SwiftData ModelContext
3. SwiftData automatically syncs to CloudKit
4. CloudKit syncs changes to other devices
5. CloudKitSyncObserver notifies the app of remote changes
6. Views update automatically via SwiftData @Query

## Testing

The project includes comprehensive test coverage:

- **Unit Tests**: Model and utility tests in `RoutinesTests/`
- **UI Tests**: End-to-end UI flow tests
- **Watch Tests**: watchOS-specific tests

Run tests from Xcode (`Cmd+U`) or via command line (see above).

## Dependencies

- **[SocialSymbols](https://github.com/jeremieb/social-symbols)** (v1.0.14+): Various Social Media Icons as SF Symbols
- **[SFSymbolsPickerForSwiftUI](https://github.com/alessiorubicini/SFSymbolsPickerForSwiftUI)** (v1.0.6+): SF Symbols picker component
- **[LicensePlist](https://github.com/mono0926/LicensePlist)** (v3.25.1+): License file generation tool

## Development Guidelines

See [AGENTS.md](AGENTS.md) for detailed development guidelines including:
- Project structure and module organization
- Coding style and naming conventions
- Testing guidelines
- Commit and pull request guidelines

## Key Features Explained

### Day Synchronization

The app includes sophisticated logic to keep routine days and step days synchronized:

- Routine days are always the superset of all step days
- Adding a day to a step automatically adds it to the parent routine
- Removing a day from a routine cascades to all steps (unless it would orphan a step)
- Steps cannot be left without any scheduled days

### CloudKit Sync

- Both iOS and watchOS apps use the same CloudKit container
- Automatic migration from local-only storage to CloudKit
- Real-time sync with push notifications
- Handles conflicts gracefully

### Completion Tracking

- Routines track completion status: incomplete, complete, or complete with skipped steps
- Steps can be marked as complete, incomplete, or skipped
- Completion status is calculated automatically based on step statuses
- Only steps scheduled for today are considered in completion calculations

## About This Project

This app is largely a learning project to help me explore and understand the ins and outs of SwiftUI and iOS development. As I continue to build and improve Routines, I'm experimenting with modern iOS frameworks, best practices, and architectural patterns.

**Tips, suggestions, and feedback are always welcome!** If you have ideas for improvements, notice areas where the code could be better, or have suggestions for learning resources, please feel free to:
- Open an issue with your thoughts
- Submit a pull request with improvements
- Share your feedback and experiences

This is a collaborative learning journey, and I appreciate any insights that can help make this project better while also helping me grow as an iOS developer.

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the coding style guidelines
4. Add tests for new functionality
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

**Especially appreciated**: Code review feedback, architectural suggestions, SwiftUI best practices, and any tips for improving the codebase!

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Social Symbols](https://github.com/jeremieb/social-symbols) - Social media icons
- [SF Symbols Picker for SwiftUI](https://github.com/alessiorubicini/SFSymbolsPickerForSwiftUI) - SF Symbols picker component
- [LicensePlist](https://github.com/mono0926/LicensePlist) - License file generation

## Support

- Website: [getroutines.app](https://getroutines.app)
- Developer: [Stygian Tech](https://stygiantech.dev)

## Version History

See the [CHANGELOG](CHANGELOG.md) for version history and release notes.

