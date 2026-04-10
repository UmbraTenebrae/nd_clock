# nd_clock

A neurodivergent-friendly clock for Android and iOS, built with Flutter.

Traditional clocks — analog or digital — require spatial reasoning and abstract number mapping that many neurodivergent children find inaccessible. nd_clock replaces the clock face with a simple horizontal progress bar that shows time as a visual portion of a whole: immediately graspable, no number literacy required.

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
- Optional labels: current time, start/end of range, time remaining as a countdown ("2h 14m left"), time remaining as plain language ("about halfway")
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

| Theme | Bar color | Background |
|-------|-----------|------------|
| Default | Black | White |
| High contrast | Black (thicker bar) | White |
| Deuteranopia-safe | Blue | Light yellow |
| Protanopia-safe | Blue | Light yellow |
| Tritanopia-safe | Red | Teal |

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
git clone https://github.com/your-username/nd_clock.git
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
│   ├── view_type.dart            # Enum: time | day | week | month | year
│   ├── color_theme_type.dart     # Color pairs per colorblind mode
│   └── selector_mode.dart        # Enum: iconAndWord | iconOnly | wordOnly
├── providers/
│   ├── settings_provider.dart    # Riverpod StateNotifier + SharedPreferences
│   └── clock_provider.dart       # Wall-clock aligned stream (1s tick)
├── utils/
│   └── time_utils.dart           # Progress math, labels, countdown, proportion
├── theme/
│   └── app_theme.dart            # ThemeData builder using Atkinson Hyperlegible
├── screens/
│   ├── clock_screen.dart         # Child-facing full-screen view
│   └── settings_screen.dart      # Caregiver settings
└── widgets/
    ├── time_progress_bar.dart    # The core progress bar widget
    └── view_selector.dart        # View-switching button row
```

**State management:** [Riverpod](https://riverpod.dev/)  
**Persistence:** [shared_preferences](https://pub.dev/packages/shared_preferences)  
**Font:** [google_fonts](https://pub.dev/packages/google_fonts) (Atkinson Hyperlegible)

---

## Roadmap

- [ ] Proportion label graphic (pie slice illustration for pre-readers)
- [ ] Optional system dark mode sync
- [ ] Home screen widget (Android / iOS)
- [ ] App Store + Google Play release

---

## License

MIT
