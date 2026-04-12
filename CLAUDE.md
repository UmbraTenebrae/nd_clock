# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter analyze          # Static analysis (must pass clean before committing)
flutter test             # Run tests
flutter run              # Run on connected device/emulator
flutter build apk        # Android release build
flutter build ios        # iOS release build
```

## Architecture

The app is named **Prism** (display name on both platforms). The Flutter package name remains `nd_clock`. State is managed with **Riverpod** (`flutter_riverpod`). Settings persist via `shared_preferences`. There is no backend.

```
lib/
  main.dart               # Entry point — wraps in ProviderScope (free rotation)
  app.dart                # MaterialApp — rebuilds theme when settings change
  models/
    app_settings.dart     # Immutable settings model with copyWith; single source of truth
    app_event.dart        # Named event (label + TimeOfDay); JSON encode/decode
    view_type.dart        # Enum: time | day | week | month | year — also carries `.icon` and `.label` extensions
    color_theme_type.dart # Enum with light/dark color pairs per colorblind mode
                          #   Separate getters: barColor, barFillColor, barTrackColor, eventColor
    selector_mode.dart    # Enum: iconAndWord | iconOnly | wordOnly
  providers/
    settings_provider.dart  # StateNotifier; loads/saves all settings to SharedPreferences
    clock_provider.dart     # StreamProvider<DateTime> — wall-clock aligned, ticks every second
  services/
    widget_service.dart   # Pushes progress/label/countdown to Android home widget via home_widget
  utils/
    time_utils.dart       # Pure functions: progressFor(), startLabelFor(), endLabelFor(),
                          #   countdownLabel(), proportionLabel(), nextEventLabel(), eventFractionFor()
  theme/
    app_theme.dart        # Builds ThemeData from AppSettings; barColor() / barFillColor() / trackColor() helpers
  screens/
    clock_screen.dart     # Full-screen child view; long-press anywhere → settings
                          #   OrientationBuilder switches between _PortraitLayout and _LandscapeLayout
                          #   Landscape: compact vertical stack, toggles + _CompactViewSelector share bottom row
                          #   ref.listen on clockProvider triggers WidgetService.update() once per minute
    settings_screen.dart  # Caregiver settings (all options)
  widgets/
    time_progress_bar.dart  # Horizontal bar with event tick marks; labels above/below alternating
    proportion_pie.dart     # CustomPainter pie slice shown beside proportion text label
    view_selector.dart      # Row of tap targets for switching ViewType
```

### Android home widget

```
android/app/src/main/
  kotlin/com/ndclock/nd_clock/
    PrismWidgetProvider.kt      # AppWidgetProvider; reads HomeWidgetPlugin SharedPrefs
  res/
    layout/prism_widget.xml     # RemoteViews layout: header, time, ProgressBar, countdown
    xml/prism_widget_info.xml   # Widget metadata: 4×2 cells, 30-min update period
  AndroidManifest.xml           # Registers PrismWidgetProvider receiver
```

## Key Design Decisions

- **Two user roles**: child (read-only, can switch views and toggle display options) and caregiver (accesses settings via 3-second long-press). Caregiver gates which toggles the child can see.
- **Progress calculation lives entirely in `time_utils.dart`**. Week starts Sunday (Dart's `weekday % 7` maps Sunday→0). Month/year use fractional day elapsed, not just day count.
- **Theme color separation**: `barColor`/`barColorDark` = UI foreground (text, icons). `barFillColor`/`barFillColorDark` = elapsed bar fill. `barTrackColor`/`barTrackColorDark` = unfilled track. `eventColor`/`eventColorDark` = upcoming event ticks. All four slots are independently specified per theme in `color_theme_type.dart`. Use `AppTheme.barFillColor()` for the bar, never `AppTheme.barColor()`.
- **Theme is derived from `AppSettings`** on every build in `app.dart` — no separate ThemeProvider. `AppTheme.build()` takes settings and returns a full `ThemeData` using Atkinson Hyperlegible via `google_fonts`.
- **Clock stream** aligns its first tick to the next whole second to avoid drift, then uses `Stream.periodic`.
- **Immersive mode** (`SystemUiMode.immersiveSticky`) is set in `ClockScreen.build()` so the system can't steal it permanently.
- **No animations on the progress bar** — `FractionallySizedBox` updates each second from the stream. The bar appears to move smoothly because seconds are small increments.
- **Orientation** is fully unlocked. `OrientationBuilder` in `ClockScreen` selects the layout; portrait uses `displayLarge` for the time, landscape uses `headlineLarge` to recover vertical space. The display toggles always get full horizontal width — never crammed into a side column.
- **`ViewType.icon`** is an extension getter on the enum (in `view_type.dart`) shared by both `ViewSelector` and `_CompactViewSelector` — do not duplicate the icon mapping elsewhere.
- **Home widget updates**: `_ClockScreenState` uses `ref.listen` on `clockProvider` in `build()` to call `WidgetService.update()` once per minute (guarded by `_lastWidgetMinute`). The Android `AppWidgetProvider` reads from `HomeWidgetPlugin` SharedPreferences written by `home_widget`.

## PRD

See `PRD.md` for full product requirements, resolved decisions, and open questions.
