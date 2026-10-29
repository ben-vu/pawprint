# Pawprint

Pawprint is an iOS app that helps new dog owners keep on top of daily care. It brings a dog's routines, health records and beginner care guides into one place, puts the next thing to do on the Home Screen, and lets you hand a sitter everything they need to know.

Built for **40005 Assignment 4** with SwiftUI and SwiftData. Animated pugs are played with Lottie.

## Features

**Home**

A greeting card for the active dog, a progress ring for today's activities and today's routine tasks. Tap the circle on a task to tick it off (tap again to undo), and the ring updates straight away. Tap the dog's photo in the navigation bar to switch dog, edit the profile, share with a sitter, add another dog or change the app's appearance. Several dogs are supported, and the chosen dog is shared across every tab.

**Routines**

Walks, meals, medication, grooming, teeth and play. Routines can repeat (daily, twice a day, weekly, certain days or every few weeks) and can send a local reminder. When a repeating routine is completed or missed, the next one is created automatically.

**Health**

Vaccinations, flea and worming treatments, vet check-ups and grooming, each with an optional follow-up date. Overdue and soon-due records are flagged, and each kind links to the matching guide in Learn.

**Animations**

The pugs on Home, Routines and Health, and the celebration after saving a health record, are Lottie animations. The JSON files live in `Pawprint/Resources/Animations/` (`SleepyPug`, `PugToiletPaper`, `PugRock`, `PugHandoff`). They are played by `LottieView`, a small SwiftUI wrapper in `Shared/Components/`. They pause when the app goes to the background, and when Reduce Motion is on they are replaced by still images.

**Learn**

A library of beginner dog care guides in six categories (Getting started, Feeding, Exercise, Training, Grooming, Health). Filter by category, bookmark guides and see a tip of the day.

**Share with a sitter**

Store your contact details, the vet, the microchip number and feeding, medical and behaviour notes for each dog (in *Edit profile*, under **For sitters**), then send a sitter a care sheet from the dog menu. You pick which sections go in (your contact details, vet, feeding, medical, behaviour, daily routine, vaccines and treatments), check a live preview and send it through the system share sheet (Messages, Mail, AirDrop and so on). Nothing leaves the phone until you tap Share, and the private notes on health records are never included.

**Appearance**

Pawprint supports Light and Dark Mode. By default it follows the device setting. To override it, tap the dog's photo on Home and choose **Appearance**: System, Light or Dark. The choice is saved on the device and applied across the whole app straight away.

**Widgets**
- *Upcoming* (small, medium, large, and Lock Screen rectangular and inline): the next routines and health follow-ups with overdue ones flagged, plus the tip of the day on the large size. Tapping a row opens the matching tab. Tap the circle beside a routine to tick it off without opening the app (health follow-ups are completed by adding a record in the app).
- *Care tip*: one Learn guide a day. If a vaccination or treatment is due within a week, the vet care guide is shown.

Widgets follow the device's Light or Dark setting. iOS doesn't pass the in-app Appearance choice to widgets, so they can differ if you override it in the app.

## Requirements

- A version of Xcode that can build for the project's deployment target, **iOS 27.0**
- Swift 6 (the widget extension is set to Swift 5 language mode)
- An Apple ID added to Xcode for signing (a free account is enough for the simulator)
- An internet connection the first time you open the project, so Xcode can download the Lottie package

The only third-party dependency is [lottie-ios](https://github.com/airbnb/lottie-ios) (version 4.6.1 or later within 4.x), added through Swift Package Manager and pinned in `Package.resolved`. Xcode fetches it automatically when you open the project. Nothing else needs installing.

## Getting started

1. Open `Pawprint.xcodeproj` and wait for Xcode to finish resolving packages (Lottie).
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
| `DashboardTests` | Creating, editing and deleting dogs, today's progress, ticking tasks off on Home |
| `RoutinesTests` | Routines, repeats, reminders |
| `HealthTests` | Health records and overdue treatments |
| `LearnTests` | Guides, filtering, bookmarks, tip of the day |
| `WidgetTests` | What the widgets show, snapshot storage, deep links, ticking tasks off in the widget |
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
  Shared/               Theme (colours, fonts, appearance setting), shared components, DomainError
  Resources/Animations/ Lottie animation JSON files
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

### Light and Dark Mode

Every colour in `PawprintTheme` is defined with a light and a dark value, so views never pick colours by hand and switch automatically. Use these instead of `Color.white`, `Color.black` or hex strings in views.

The user's choice lives in `AppearanceSetting` (`Shared/Theme/`). It is stored in `UserDefaults` under `AppearanceSetting.storageKey` and applied once in `PawprintApp` with `.preferredColorScheme`. `.system` maps to `nil`, which follows the device. The picker is in `DogSwitcherMenu`. The widget has its own matching palette in `WidgetPalette`, so keep the two in sync when changing colours.

### How the widgets get their data

The widget never opens the SwiftData store. Instead:

1. `WidgetSyncService` listens for every SwiftData save.
2. `RefreshWidgetUseCase` builds a `WidgetSnapshot` (upcoming tasks, health follow-ups, a week of tips, dog count) using `BuildWidgetSnapshotUseCase`.
3. The snapshot is written as JSON to the App Group's `UserDefaults`, and WidgetKit is asked to reload, but only if something visible changed.
4. The widget's timeline provider reads the snapshot and schedules a redraw at each due time and at midnight.

#### Ticking tasks off in the widget

The widget still never opens SwiftData, so a tap on a routine's circle (`CompleteRoutineIntent`) does two small things in the App Group:

1. It adds the task's id (`UpcomingTask.taskID`, the routine's `reminderID`) to a queue, `PendingCompletionStore`.
2. It removes the task from the saved snapshot, so the widget updates immediately. The timeline provider also hides any queued task, so it can't flash back.

The app applies the queue in `WidgetSyncService.applyPendingCompletions()`, on launch and every time it becomes active. That runs `ApplyWidgetCompletionsUseCase`, which reuses `CompleteRoutineUseCase`, so ticking in the widget behaves exactly like ticking in the app: the reminder is cancelled and the next occurrence of a repeating routine is created. Home and Routines reload when it finishes (`.widgetCompletionsApplied`).

Until the app next opens, the task's reminder can still fire and the next occurrence of a repeating routine won't show in the widget yet.

Taps use `pawprint://` links (`home`, `routines`, `health`, `learn/<guide-id>`). They are defined once in `PawprintDeepLink` and handled by `AppRouter`.

Care details for sitters are deliberately **not** part of the snapshot, so personal information is never available to the widget.

### Adding an animation

1. Drop the Lottie `.json` file into `Pawprint/Resources/Animations/` and make sure it is in the **Pawprint** target.
2. Show it with `LottieView(name: "FileNameWithoutExtension")`. It loops by default. Pass `loops: false` and `onFinished:` to play it once.
3. Check `@Environment(\.accessibilityReduceMotion)` and show a still image instead when it is on, as the existing animations do.

### Adding a field to a model

Give new `@Model` properties a default value (for example `var notes: String = ""`) so existing stores migrate without a manual migration. The sitter care fields on `Dog` were added this way.

## Privacy

All data stays on the device. There is no account, no analytics and no networking code. Lottie only plays animation files bundled with the app and makes no network requests; it is downloaded once at build time, not at run time. The privacy manifests declare only `UserDefaults` use, which the app and widget need to share the widget snapshot, and which also stores your Appearance choice. Care details are only sent when you choose to share them.

## Contributors

- Natalie Michael: Dashboard (dogs, Home, onboarding, profiles), UI
- Sana Yousefi: Routines, notifications, UI
- Alik Orgun: Health
- Benjamin Vu: Learn, widgets

## Credits

The Nunito typeface is used under the SIL Open Font License. See `Pawprint/Resources/Fonts/Nunito-LICENSE.txt`.

[lottie-ios](https://github.com/airbnb/lottie-ios) by Airbnb is used under the Apache 2.0 License.
