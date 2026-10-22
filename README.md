# Pawprint

Pawprint is an iOS app that helps new dog owners keep on top of daily care. It brings a dog's routines, health records and beginner care guides into one place, puts the next thing to do on the Home Screen, and lets you hand a sitter everything they need to know.

Built for **40005 Assignment 4** with SwiftUI and SwiftData.

## Features

**Home**

A greeting card for the active dog, a progress ring for today's activities and today's routine tasks. Tap the dog's photo in the navigation bar to switch dog, edit the profile, share with a sitter or add another dog. Several dogs are supported, and the chosen dog is shared across every tab.

**Routines**

Walks, meals, medication, grooming, teeth and play. Routines can repeat (daily, twice a day, weekly, certain days or every few weeks) and can send a local reminder. When a repeating routine is completed or missed, the next one is created automatically.

**Health**

Vaccinations, flea and worming treatments, vet check-ups and grooming, each with an optional follow-up date. Overdue and soon-due records are flagged, and each kind links to the matching guide in Learn.

**Learn**

A library of beginner dog care guides in six categories (Getting started, Feeding, Exercise, Training, Grooming, Health). Filter by category, bookmark guides and see a tip of the day.

**Share with a sitter**

Store your contact details, the vet, the microchip number and feeding, medical and behaviour notes for each dog (in *Edit profile*, under **For sitters**), then send a sitter a care sheet from the dog menu. You pick which sections go in (your contact details, vet, feeding, medical, behaviour, daily routine, vaccines and treatments), check a live preview and send it through the system share sheet (Messages, Mail, AirDrop and so on). Nothing leaves the phone until you tap Share, and the private notes on health records are never included.

**Widgets**
- *Upcoming* (small, medium, large, and Lock Screen rectangular and inline): the next routines and health follow-ups with overdue ones flagged, plus the tip of the day on the large size. Tapping opens the matching tab.
- *Care tip*: one Learn guide a day. If a vaccination or treatment is due within a week, the vet care guide is shown.

## Requirements

- A version of Xcode that can build for the project's deployment target, **iOS 27.0**
- Swift 6 (the widget extension is set to Swift 5 language mode)
- An Apple ID added to Xcode for signing (a free account is enough for the simulator)

There are no third-party dependencies.

## Getting started

1. Open `Pawprint.xcodeproj`.
2. For both the **Pawprint** and **PawprintWidgetExtension** targets, open *Signing & Capabilities* and choose your team.
3. The widget reads data from the app through an App Group. The project uses `group.com.nootnoot.pawprint` and bundle ids starting with `com.nootnoot.pawprint`. If you change your bundle ids you will probably need a different App Group too. Change it in all three places so they match exactly:
   - `Pawprint/Pawprint.entitlements`
   - `PawprintWidget/PawprintWidget.entitlements`
   - `WidgetConfig.appGroupID` in `PawprintWidgetShared/WidgetConfig.swift`
4. Select the **Pawprint** scheme, pick a simulator or device and run.
5. To add a widget, long-press the Home Screen, tap **+** and search for Pawprint.

If the widget always shows "All caught up", or "Open Pawprint to load today's tip", the App Group is the usual cause: the app and the widget must agree on its name, and both targets need the App Groups capability.

## Running the tests

In Xcode press **Cmd+U**, or from the command line:

```sh
xcodebuild test -project Pawprint.xcodeproj -scheme Pawprint \
  -destination 'platform=iOS Simulator,name=<a simulator you have>'
```

Unit tests use [Swift Testing](https://developer.apple.com/documentation/testing) against mock repositories, so most never touch a real database (a few widget tests use an in-memory SwiftData container). The UI tests in `PawprintUITests` drive the real app, and some skip themselves until onboarding has been completed on the simulator.

| Test folder | Covers |
| --- | --- |
| `DashboardTests` | Creating, editing and deleting dogs, today's progress |
| `RoutinesTests` | Routines, repeats, reminders |
| `HealthTests` | Health records and overdue treatments |
| `LearnTests` | Guides, filtering, bookmarks, tip of the day |
| `WidgetTests` | What the widgets show, snapshot storage, deep links |
| `SharingTests` | Care details and the sitter care sheet |
| `SharedTests` | Fonts |

## Project structure

```
Pawprint/
  App/                  App entry point, root view, tab bar, deep-link router
  Features/
    Dashboard/          Dogs, Home, onboarding, profile editing, dog switcher
    Routines/           Routine tasks, repeats, reminders
    Health/             Health records
    Learn/              Care guides
    Sharing/            Care details and the sitter care sheet
    Widget/             App-side code that feeds the widgets
  Shared/               Theme, shared components, DomainError
  Resources/Fonts/      Nunito (see Nunito-LICENSE.txt)
PawprintWidget/         Widget extension: timeline, views, palette
PawprintWidgetShared/   Code compiled into both the app and the widget
PawprintTests/          Unit tests
PawprintUITests/        UI tests
```

### Architecture

Each feature follows the same layers, so views stay thin and logic stays testable:

- **Models**: SwiftData `@Model` types (`Dog`, `RoutineTask`, `HealthRecord`, `LearnTip`) and small value types.
- **Repositories**: a protocol plus a SwiftData implementation. View models and use cases only see the protocol, so tests can swap in a mock.
- **Use cases**: one struct per business operation, with validation inside and errors expressed as `DomainError` enums.
- **View models**: `@Observable` classes that hold screen state and call use cases.
- **Views**: SwiftUI views that use `PawprintTheme` (light and dark colours, Nunito fonts that scale with Dynamic Type).

### How the widgets get their data

The widget never opens the SwiftData store. Instead:

1. `WidgetSyncService` listens for every SwiftData save.
2. `RefreshWidgetUseCase` builds a `WidgetSnapshot` (upcoming tasks, health follow-ups, a week of tips, dog count) using `BuildWidgetSnapshotUseCase`.
3. The snapshot is written as JSON to the App Group's `UserDefaults`, and WidgetKit is asked to reload, but only if something visible changed.
4. The widget's timeline provider reads the snapshot and schedules a redraw at each due time and at midnight.

Taps use `pawprint://` links (`home`, `routines`, `health`, `learn/<guide-id>`). They are defined once in `PawprintDeepLink` and handled by `AppRouter`.

Care details for sitters are deliberately **not** part of the snapshot, so personal information is never available to the widget.

### Adding a field to a model

Give new `@Model` properties a default value (for example `var notes: String = ""`) so existing stores migrate without a manual migration. The sitter care fields on `Dog` were added this way.

## Privacy

All data stays on the device. There is no account, no analytics and no networking code. The privacy manifests declare only `UserDefaults` use, which the app and widget need to share the widget snapshot. Care details are only sent when you choose to share them.

## Contributors

- Natalie Michael: Dashboard (dogs, Home, onboarding, profiles), UI
- Sana Yousefi: Routines, notifications, UI
- Alik Orgun: Health
- Benjamin Vu: Learn, widgets

## Credits

The Nunito typeface is used under the SIL Open Font License. See `Pawprint/Resources/Fonts/Nunito-LICENSE.txt`.
