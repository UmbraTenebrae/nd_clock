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

State is managed with **Riverpod** (`flutter_riverpod`). Settings persist via `shared_preferences`. There is no backend.

```
lib/
  main.dart               # Entry point — locks portrait, wraps in ProviderScope
  app.dart                # MaterialApp — rebuilds theme when settings change
  models/
    app_settings.dart     # Immutable settings model with copyWith; single source of truth
    view_type.dart        # Enum: time | day | week | month | year
    color_theme_type.dart # Enum with light/dark color pairs per colorblind mode
    selector_mode.dart    # Enum: iconAndWord | iconOnly | wordOnly
  providers/
    settings_provider.dart  # StateNotifier; loads/saves all settings to SharedPreferences
    clock_provider.dart     # StreamProvider<DateTime> — wall-clock aligned, ticks every second
  utils/
    time_utils.dart       # Pure functions: progressFor(), startLabelFor(), endLabelFor(),
                          #   countdownLabel(), proportionLabel()
  theme/
    app_theme.dart        # Builds ThemeData from AppSettings; barColor() / trackColor() helpers
  screens/
    clock_screen.dart     # Full-screen child view; long-press anywhere → settings
    settings_screen.dart  # Caregiver settings (all options)
  widgets/
    time_progress_bar.dart  # Horizontal bar; FractionallySizedBox driven by progress double
    view_selector.dart      # Row of tap targets for switching ViewType
```

## Key Design Decisions

- **Two user roles**: child (read-only, can switch views and toggle display options) and caregiver (accesses settings via 3-second long-press). Caregiver gates which toggles the child can see.
- **Progress calculation lives entirely in `time_utils.dart`**. Week starts Sunday (Dart's `weekday % 7` maps Sunday→0). Month/year use fractional day elapsed, not just day count.
- **Theme is derived from `AppSettings`** on every build in `app.dart` — no separate ThemeProvider. `AppTheme.build()` takes settings and returns a full `ThemeData` using Atkinson Hyperlegible via `google_fonts`.
- **Clock stream** aligns its first tick to the next whole second to avoid drift, then uses `Stream.periodic`.
- **Immersive mode** (`SystemUiMode.immersiveSticky`) is set in `ClockScreen.build()` so the system can't steal it permanently.
- **No animations on the progress bar** — `FractionallySizedBox` updates each second from the stream. The bar appears to move smoothly because seconds are small increments.

## PRD

See `PRD.md` for full product requirements, resolved decisions, and open questions.
