# Changelog

All notable changes to this project will be documented in this file.

## [1.2.2] - 2026-09-13
### Fixed
- **Standard Calculator**: Replaced floating-point arithmetic with exact rational arithmetic to prevent large numbers from losing digits or gaining trailing zeros (e.g. `123456789123456767` remains unchanged after pressing `=`).
- **Standard Calculator**: Separated the internal result from its display formatting so chained calculations and history reuse preserve precision.
- **Unit Converters**: Clear the opposite result field when the active input is incomplete, invalid, or non-finite, preventing stale results across all 12 converters in both directions.
- **Significant Figures**: Validate the supported range of 1–21 and disable confirmation for empty or invalid input. Changes are saved only on confirmation; cancelling or dismissing the dialog leaves the setting unchanged. Invalid saved values fall back to the default.
- **Date Calculator**: Compare calendar dates independently of daylight saving time, fixing incorrect differences across clock changes. Equal dates now explicitly display zero days.
- **Localization**: Localized page titles, syntax errors, the empty-history state, About screen labels, and the Buy Me a Coffee entry in all supported languages. Regenerated localization sources with no untranslated messages remaining.

### Improved
- **Number Display**: Preserve all integer digits below `10^21` and use scientific notation for larger results, without changing the exact internal value. Very small nonzero results below `10^-6` also use scientific notation.
- **Numeric Input**: Prevent multiple decimal points within the same number in the standard calculator, all unit converters, and the tip calculator. Apply the same validation to keypad, pasted, and hardware-keyboard input while allowing expressions such as `1.2 + 3.4`.
- **Calculator Input**: Ignore arithmetic operators entered immediately after another operator, while keeping repeated percentage symbols available.
- **Percentages**: Support repeated percentages, including `50%% = 0.005` and `9%%60 = 0.054`, alongside existing commercial percentage calculations.
- **Release Versioning**: Centralized the app version and Android build number in `pubspec.yaml`; the About screen now reads and displays both values from the installed package.
- **Language Selection**: Use the first supported device language on initial launch, falling back to English only when necessary, while preserving the user's saved choice on subsequent launches.
- **About Screen**: Added the app description, version and build, developer information, a GitHub link with theme-aware icons, open-source dependency licenses, and the GNU GPL v3 copyright notice.
- **Project Requirements**: Declared Flutter as a direct dependency and aligned the minimum Dart and Flutter versions with the current lockfile requirements.
- **Release Documentation**: Consolidated the duplicated release guides into a single checklist and updated its versioning instructions for the centralized release configuration.

### Tests
- Expanded the automated suite to 57 tests covering large numbers, exact chained calculations, scientific notation, repeated percentages, input validation, converter recovery, settings persistence, first-launch language selection, and calendar differences across daylight saving changes and leap years.

## [1.2.1] - 2026-08-30
### Fixed
- **UI / Dark Mode**: Fixed white screen flash glitch during page transitions (Settings, About, Theme) in Dark Mode by ensuring transparent transition backgrounds.
- **Unit Converters**: Real-time automatic recalculation across all 12 converters when switching units in either dropdown without having to retype numbers.
- **Unit Converters**: Fixed focus loss issue when opening dropdown menus and ensured proper controller/focus node disposal.
- **Standard Calculator**: Fixed `RangeError` and uncaught exceptions when evaluating expressions or pressing `=` on incomplete inputs.
- **Standard Calculator**: Fixed floating-point precision artifacts (e.g. `9%60` now cleanly evaluates to `5.4` instead of `5.3999999999999995`).
- **Standard Calculator**: Added support for standard commercial percentage calculations (e.g. `10 - 20% = 8`, `10 + 20% = 12`).
- **Android**: Updated Android target SDK to 36.

### Improved
- **Smart Parentheses**: Intelligent contextual `()` button in Standard Calculator that automatically opens `(`, closes `)`, handles implicit multiplication `*(`, wraps text selections, and auto-closes parentheses on `=`.
- **Percentage Display**: Displays the clean `%` symbol directly in the expression rather than `/100*`.


## [1.2.0] - 2026-02-20
### Added
- Time Calculator with two tabs:
  - Time Difference: calculate the difference between two times (hours and minutes)
  - Add/Subtract Time: add or subtract hours and minutes from a selected time
- New translations for Time Calculator in all supported languages (EN, IT, ES, FR, RO)
- New navigation drawer entry for Time Calculator (between Standard and Date)

### Fixed
- Updated `MainActivity.kt` to Flutter Embedding v2
- Upgraded Android Gradle Plugin (8.5.2 → 8.9.1), Kotlin (1.9.20 → 2.1.0), Gradle (8.8 → 8.11.1)
- Fixed time difference calculation across midnight (e.g. 23:30 → 06:30 = 7h)

## [1.1.9] - 2025-09-01
- Fix security problem
- Fix support 16 KB page sizes 


## [1.1.8] - 2025-08-10
### Changed
- Update to target API 35
- Update pubspec.yaml
- Fix icons and theme icon

## [1.1.7]
### Changed
- Update targetAPI from 33 (Android 13) to 34 (Android 14) (updating Flutter)
- Update minSdkVersion (from Flutter)
- Move "Manufacturer" at the top of the support email

### Fixed
- Bug fixing

## [1.1.6]
### Added
- "Android Info" in settings page
- "App Info" in settings page
- "Contact Me" section with email functionality
- Email with android info and app info integration

### Changed
- Updated translations

### Fixed
- Fixed bugs

## [1.1.5]
### Added
- Power Converter
- Energy Converter
- Tip Converter with:
  - Text fields for "Amount", "Tip percentage", "Tip Amount", "Total Amount"
  - Numbers keyboard
  - Translations support

### Fixed
- Fixed "Leave review" functionality
- Fix "Bottom overflow" for Power Converter
- Fix "Bottom overflow" for Energy Converter
- Updated translations
- Fixed bugs

## [1.1.4]
### Added
- Romanian language support
- "Leave a review" functionality
- "Buy me a coffee" option
- "Selected language" indicator

### Changed
- Update settings page

## [1.1.3]
### Added
- Button to clean history
- Toast notification for clean history (with language support)
- Language support for "Set significant figures" and buttons

### Fixed
- Correct "theme from system" (package incorrect)
- Fixed "Expanded" in converter layouts
- Corrected "theme color from system"
- Fixed converters screen layout
- Improved languages

## [1.1.2]
### Added
- Language support and translations
- Layout improvements for calculator (0 and "." buttons)

### Changed
- Change app name
- Change package name
- Change app icon
- Change color scheme

### Fixed
- Main update with various improvements

## [1.1.1]
### Added
- Haptic feedback functionality

### Fixed
- Fixed haptic feedback issues

## [1.1.0]
### Fixed
- Bug fixes
- Optimized for landscape orientation and larger devices

## [1.0.0]
### Added
- First release of LapisCalc
