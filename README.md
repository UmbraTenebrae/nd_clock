# Prism

A neurodivergent-friendly clock for Android and iOS, built with Flutter.

Traditional clocks — analog or digital — require spatial reasoning and abstract number mapping that many neurodivergent children find inaccessible. Prism replaces the clock face with a simple horizontal progress bar that shows time as a visual portion of a whole: immediately graspable, no number literacy required.

Designed primarily for autistic children ages 4–12, with dyslexia and dyscalculia as first-class considerations.

---

## Features

### Linear time display

The entire screen is a single horizontal progress bar. The bar fills left-to-right as time passes. No hands. No abstract symbols.

Five views, one at a time:

| View | What the bar shows | Display label | Countdown |
|------|-------------------|---------------|-----------|
| **Time** | A caregiver-configured time range (e.g. 8 AM – 4 PM), or a 12/24-hour default | Current time | `2h 14m left` |
| **Day** | Midnight to midnight | Current time | `2h 14m left` |
| **Week** | Sunday to Saturday | Day name (e.g. *Wednesday*) | `3 days left` |
| **Month** | Days elapsed in the current month | Month and day (e.g. *April 10*) | `18 days left` |
| **Year** | Days elapsed in the current year | Month name (e.g. *April*) | `8 months left` |

Each view shows the most meaningful unit of time — not just hours and minutes when the bar represents a whole week or year.

### Child-friendly interface

- Full-screen immersive display — no system chrome or distractions
- Responsive to device orientation: portrait and landscape both maintain large, readable controls
- Large touch targets throughout (minimum 48×48dp)
- View switching via large icon + word buttons (icon-only or word-only also available)
- Optional labels: current time, start/end of range, time remaining as a countdown ("2h 14m left"), time until next event ("2h until Lunch"), time remaining as plain language ("about halfway") with a pie-slice graphic for pre-readers
- Event markers: caregiver can pin named events to the Time bar (e.g. "Lunch", "Home") — displayed as tick marks with optional labels
- All child-facing controls are toggle-only — children cannot access or change settings

### Caregiver settings

Accessed by long-pressing anywhere on the screen for 3 seconds. No PIN required.

- Choose which views the child can access
- Set a custom time range for the Time view
- Toggle 12/24-hour format
- Adjust font size
- Choose a color theme (including colorblind-friendly modes)
- Toggle dark mode
- Control which display options the child can turn on or off

### Accessibility

**Typography:** [Atkinson Hyperlegible](https://brailleinstitute.org/freefont) — designed by the Braille Institute for low-vision readers, with highly distinct numeral shapes that also benefit users with dyscalculia.

**Color themes** — all built-in themes meet WCAG AA contrast (4.5:1 minimum):

| Theme | Bar fill | Event ticks | Background |
|-------|----------|-------------|------------|
| Default | Red | Black | White |
| High contrast | Red (thicker bar) | Black | White |
| Deuteranopia-safe | Blue | Orange | Light yellow |
| Protanopia-safe | Blue | Orange | Light yellow |
| Tritanopia-safe | Red | Purple | Teal |

Elapsed bar, event tick marks, and unfilled track each use distinct colors to avoid ambiguity. All themes have dark-mode equivalents.

Every theme has a dark mode equivalent. Dark mode is an explicit toggle — it does not rely solely on the system setting.

---

## Getting Started

### Requirements

- Flutter 3.41 or later
- Dart 3.11 or later
- Android SDK (for Android builds) — minimum target API 26 (Android 8.0)
- Xcode (for iOS builds) — minimum target iOS 14

### Install and run

```bash
git clone https://github.com/UmbraTenebrae/nd_clock.git
cd nd_clock
flutter pub get
flutter run
```

### Build for release

```bash
flutter build apk        # Android
flutter build ios        # iOS (requires macOS + Xcode)
```

---

## Project Structure

```
lib/
├── main.dart                     # Entry point
├── app.dart                      # MaterialApp, theme wiring
├── models/
│   ├── app_settings.dart         # All caregiver settings (immutable + copyWith)
│   ├── app_event.dart            # Named event (label + TimeOfDay)
│   ├── view_type.dart            # Enum: time | day | week | month | year
│   ├── color_theme_type.dart     # Color pairs per colorblind mode
│   └── selector_mode.dart        # Enum: iconAndWord | iconOnly | wordOnly
├── providers/
│   ├── settings_provider.dart    # Riverpod StateNotifier + SharedPreferences
│   └── clock_provider.dart       # Wall-clock aligned stream (1s tick)
├── services/
│   └── widget_service.dart       # Pushes state to Android home screen widget
├── utils/
│   └── time_utils.dart           # Progress math, labels, countdown, proportion
├── theme/
│   └── app_theme.dart            # ThemeData builder using Atkinson Hyperlegible
├── screens/
│   ├── clock_screen.dart         # Child-facing full-screen view
│   └── settings_screen.dart      # Caregiver settings
└── widgets/
    ├── time_progress_bar.dart    # Progress bar with event tick marks
    ├── proportion_pie.dart       # Pie-slice graphic for proportion label
    └── view_selector.dart        # View-switching button row
```

**State management:** [Riverpod](https://riverpod.dev/)  
**Persistence:** [shared_preferences](https://pub.dev/packages/shared_preferences)  
**Font:** [google_fonts](https://pub.dev/packages/google_fonts) (Atkinson Hyperlegible)  
**Home widget:** [home_widget](https://pub.dev/packages/home_widget)

---

## Roadmap

- [x] Proportion label graphic (pie slice illustration alongside "about halfway" text)
- [x] Home screen widget (Android) — shows active view progress bar, current time, and countdown; updates once per minute while app is open, every 30 minutes from system
- [ ] Home screen widget (iOS) — requires WidgetKit extension added via Xcode; Swift scaffolding ready once target is created
- [ ] Optional system dark mode sync
- [ ] App Store + Google Play release

---

## License

MIT
