# Product Requirements Document: nd_clock

**Version:** 0.4
**Last Updated:** 2026-04-12
**Author:** Solo project
**Platform:** Flutter (Android + iOS)
**Distribution:** App Store + Google Play (eventual public release)

---

## 1. Problem Statement

Analog clocks require spatial reasoning and abstract symbol mapping that is inaccessible to many neurodivergent children. Standard digital clocks show a moment in time but give no sense of *where that moment sits* within a larger span — making time blindness worse, not better. Children with autism, dyslexia, or dyscalculia frequently struggle to:

- Read traditional clock faces (hands, Roman numerals, spatial layout)
- Understand how much time has passed or remains
- Intuitively grasp time as a *quantity* rather than a label

**nd_clock** replaces the abstract clock face with a concrete, linear progress bar that shows time as a visual portion of a whole — an immediately graspable representation even for pre-readers and children with number-processing difficulties.

---

## 2. Target Users

**Primary user (child):** Ages 4–12, predominantly autistic. May also have dyslexia or dyscalculia. Will use the app in read-only mode — switching between pre-configured views but not changing settings.

**Secondary user (caregiver):** Parent, teacher, or therapist who performs initial configuration and sets the options available to the child. Should not need technical knowledge to complete setup.

---

## 3. Goals

- Make the passage of time visually self-evident without requiring number literacy
- Eliminate the cognitive load of analog clock reading
- Support time scales from a single day segment to a full year
- Be fully usable by a child who cannot yet read numbers
- Be publishable to App Store and Google Play

---

## 4. Non-Goals (v1)

- Alerts, timers, or countdowns
- Calendar or external app integration
- Multi-user profiles
- Network connectivity features
- Tablet-specific layouts (phone-first, tablet graceful degradation acceptable)

---

## 5. Core Feature: Linear Progress Bar

### 5.1 Visual Design

- A single horizontal progress bar occupying the majority of the screen
- The bar fills left-to-right, representing elapsed time within the selected range
- Real-time animation: the fill moves continuously and smoothly (no tick-based jumps)
- Full-screen immersive display; no system chrome, navigation bars, or distracting UI elements

### 5.2 Time Views

The user selects one active view at a time. Views available:

| View | Bar represents | "Now" marker |
|------|---------------|--------------|
| **Time** | Configured time range (e.g., 8am–4pm) | Current time within that range |
| **Day** | Midnight to midnight (24h) | Current time |
| **Week** | Sunday 00:00 to Saturday 23:59 | Current day/time |
| **Month** | Day 1 to last day of current month (% of days elapsed) | Current day |
| **Year** | Jan 1 to Dec 31 (% of days elapsed) | Current day |

Switching between views is a simple swipe or large tap — accessible to a child without reading.

### 5.3 Time Range Configuration (Time View)

- Default: **12-hour** (12:00am – 11:59pm) or **24-hour** (00:00 – 23:59), caregiver selectable
- Custom range: caregiver sets a start time and end time (e.g., 7:00am – 7:00pm for a child's waking day)
- If current time is outside the configured range, the bar shows 0% (before) or 100% (after) with a clear visual indicator

### 5.4 Rollover Behavior

- When a time range ends (bar reaches 100%), the bar resets to 0% at the start of the next cycle
- Time view: resets at the configured start time each day
- Day view: resets at midnight
- Week view: resets at Sunday 00:00
- Month view: resets on the 1st of each month
- Year view: resets on January 1st
- No animation or special treatment at rollover — the bar simply reflects the current position in the new cycle

---

## 6. Display Options (Caregiver-Configured, Child-Toggleable)

Each option below can be enabled or disabled by the caregiver in settings. Enabled options appear as large, obvious toggle buttons on the main screen so the child can turn them on or off.

| Option | Description |
|--------|-------------|
| **Current time** | Digital time display in large, dyslexia-friendly font (always visible) |
| **Start / End labels** | Shows the start and end values at the left and right ends of the bar |
| **Time remaining (countdown)** | e.g., "2h 14m left"; also shows "2h until Lunch" if an event is upcoming |
| **Time remaining (proportion)** | e.g., "about a quarter left" — plain-language fractions alongside a pie-slice graphic |
| **Event labels** | Named event markers on the Time bar (e.g., "Lunch", "Home"); past events grey, future events theme-colored |

Both time-remaining formats can be active simultaneously if the caregiver enables both.

---

## 7. Accessibility

### 7.1 Typography

- Use **Atkinson Hyperlegible** throughout (designed by the Braille Institute; strong numeral differentiation addresses both dyslexia and dyscalculia needs)
- Font size: large by default; caregiver can adjust in settings
- No italics. Minimal use of bold (only for emphasis where critical)
- Labels use simple, short words. Proportion labels use language a 4-year-old can understand ("almost done", "about halfway", "just started")

### 7.2 Color

**Default theme:** Red progress bar on white background; event tick marks in black for contrast against both bar and track.

**Colorblind-friendly modes** (caregiver selects):

| Mode | Bar fill | Event ticks | Background |
|------|----------|-------------|------------|
| Default | Red | Black | White |
| High contrast | Red (thicker bar) | Black | White |
| Deuteranopia-safe | Blue | Orange | Light yellow |
| Protanopia-safe | Blue | Orange | Light yellow |
| Tritanopia-safe | Red | Purple | Teal |

Each color slot (bar fill, event ticks, unfilled track) is independently specified per theme to ensure legibility without color confusion. All built-in themes pass WCAG AA contrast ratio (4.5:1 minimum). All themes have dark-mode equivalents.

### 7.3 Light / Dark Mode

- Explicit dark mode toggle in settings (do not rely solely on system setting)
- Dark mode inverts the default: white bar on dark background
- All colorblind themes have dark-mode equivalents

### 7.4 Interaction Accessibility

- All interactive elements are large touch targets (minimum 48×48dp)
- No small text, fine motor precision, or double-tap required for child-facing controls
- Child view has no destructive or settings-altering controls — they can only switch views and toggle display options

---

## 8. App Structure

### 8.1 Child View (Primary Screen)

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│   [Current time: large font]                         │
│                                                      │
│   ████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
│   [start label]                        [end label]  │
│                                                      │
│   [time remaining countdown]                         │
│   [time remaining proportion]                        │
│                                                      │
│    [icon]  [icon]   [icon]   [icon]   [icon]        │
│    TIME    DAY      WEEK     MONTH    YEAR           │
│                                                      │
└──────────────────────────────────────────────────────┘
```

- View selector uses large buttons with both an icon and a word label
- Icon conveys meaning for pre-readers; word label reinforces it for readers
- Caregiver can choose to show icons-only, words-only, or both (default: both)
- Only caregiver-enabled views appear in the selector
- Display option toggles (start/end, time remaining) appear as large buttons if caregiver has enabled them

### 8.2 Caregiver Settings (Access-Controlled)

Settings are accessed by long-pressing a corner of the screen for 3 seconds. No PIN required — the deliberate gesture is sufficient to prevent accidental access by children.

Settings include:
- Active time views (which views the child can access)
- View selector display mode: icon + word (default), icon only, word only
- Time range for the Time view
- 12h / 24h default
- Font size
- Color theme / colorblind mode
- Dark mode toggle
- Which display options the child can toggle

---

## 9. Technical Notes

- **Framework:** Flutter (single codebase for Android + iOS)
- **Minimum target OS:** Android 8.0 (API 26), iOS 14
- **State management:** TBD (provider/riverpod recommended for this scale)
- **Persistence:** Caregiver settings stored locally via `shared_preferences` or `flutter_secure_storage`
- **No backend required for v1**
- Progress bar updates from a `StreamProvider<DateTime>` aligned to wall-clock seconds; no `AnimationController` needed — sub-second drift is imperceptible at this time scale
- **Home screen widget (Android):** `AppWidgetProvider` (`PrismWidgetProvider`) reads progress, view label, current time, and countdown from SharedPreferences written by Flutter via `home_widget`. System minimum update period is 30 minutes; Flutter pushes updates once per minute while the app is in foreground.

---

## 10. Open Questions

- [ ] Should dark mode also follow the system setting automatically as a secondary option? *(deferred)*

**Resolved:**
- [x] Font: **Atkinson Hyperlegible** throughout
- [x] View selector: icon + word by default; caregiver can switch to icon-only or word-only
- [x] Bar rollover: resets to 0% at the start of each new cycle, no special animation
- [x] Caregiver settings access: long-press corner for 3 seconds, no PIN
- [x] Week starts Sunday 00:00, ends Saturday 23:59
- [x] Proportion label graphic: pie-slice `CustomPainter` displayed inline left of the proportion text; uses bar fill and track colors for visual consistency
- [x] Home screen widget: Android only (v1); iOS requires WidgetKit extension target added via Xcode

---

## 11. Success Criteria (v1)

- A child aged 4–12 can independently read the current view and switch between views without caregiver assistance
- A caregiver can complete initial setup in under 5 minutes without reading a manual
- The app passes WCAG AA contrast requirements in all built-in themes
- The progress bar accurately reflects wall-clock time with no perceptible drift
- Builds and runs on both Android and iOS from a single Flutter codebase
