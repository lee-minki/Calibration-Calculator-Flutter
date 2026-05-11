# ⚙️ Calibration Calculator

A professional Flutter mobile application for industrial instrumentation calibration calculations, designed for field engineers and technicians working with control systems and sensors.

> **Latest Release**: v1.0.2 - Optimized for modern Android devices (Galaxy S24/S25)

## 🎯 Overview

Calibration Calculator provides two essential calculation tools for process control instrumentation:

- **Loop Calculator**: Converts values between input/output ranges (4-20mA signal scaling)
- **Positioner Calculator**: Calculates DCS (Distributed Control System) settings for valve positioner calibration

Built with Flutter for a smooth, native mobile experience with an elegant dark-themed UI and custom numeric keypad for precise data entry.

## ✨ Features

### 🔄 Loop Calculator
- **Input/Output Range Mapping**: Convert process values to 4-20mA signals and vice versa
- **Configurable Ranges**: Customize both input and output ranges
- **Quick Percentage Buttons**: Instantly calculate values at 0%, 25%, 50%, 75%, and 100%
- **Visual Bar Graph**: Real-time visual representation of output percentage
- **Precision Calculation**: Support for decimal values with automatic formatting

### 🎚️ Positioner Calculator
- **DCS Setting Calculation**: Determine optimal zero and span settings for valve positioners
- **Physical Measurement Input**: Enter actual sensor readings for calibration
- **Desired Range Configuration**: Set target DCS percentage ranges
- **Zone Visualization**: Visual indicators for zero zone (-5% to 5%) and span zone (95% to 105%)
- **Compact Layout**: Optimized for single-screen operation without scrolling

### 📱 User Experience
- **Dark Theme**: Professional dark UI optimized for field conditions
- **Custom Keypad**: Built-in numeric keypad with decimal and sign support
- **Haptic Feedback**: Tactile responses for button presses and selections
- **Portrait-Only**: Locked orientation for consistent operation
- **AdMob Integration**: Banner ads with non-intrusive placement

## 🚀 Installation

### For End Users

Download the latest release from the [Releases](https://github.com/lee-minki/Calibration-Calculator-Flutter/releases) page:

1. Download `CalibrationCalculator-v1.0.2.aab` or `.apk` file
2. Install on your Android device
3. Launch and start calculating

### For Developers

**Prerequisites**:
- Flutter SDK 3.10.4 or higher
- Dart SDK
- Android Studio or VS Code with Flutter extensions

**Setup**:

```bash
# Clone the repository
git clone https://github.com/lee-minki/Calibration-Calculator-Flutter.git
cd Calibration-Calculator-Flutter

# Install dependencies
flutter pub get

# Run the app
flutter run
```

**Build for production**:

```bash
# One-liner (from repo root) — builds AAB + APK and prints the output paths.
./scripts/release.sh both        # or: aab | apk

# Or invoke Flutter directly from flutter/
flutter build appbundle --release
flutter build apk --release
```

**Signing the release build**:

The Gradle config resolves keystore credentials from environment variables
first, then falls back to `android/key.properties`. If neither is present,
the release build falls back to **debug signing** (with a warning) so local
builds never break.

Local development:

```bash
cp android/key.properties.example android/key.properties
# edit values, then place the keystore at:
#   android/app/upload-keystore.jks
```

CI / shared machines (preferred):

```bash
export ANDROID_KEYSTORE_PATH=/abs/path/to/upload-keystore.jks
export ANDROID_KEYSTORE_PASSWORD=…
export ANDROID_KEY_PASSWORD=…
export ANDROID_KEY_ALIAS=upload
flutter build appbundle --release
```

`versionName` / `versionCode` come **only** from `pubspec.yaml` — bump them
there and tag the commit (`git tag v1.0.3 && git push --tags`) to trigger
the GitHub Actions release workflow.

## 📖 Usage

### Loop Calculator

1. **Set Input Range**: Tap on INPUT LOW and INPUT HIGH to configure your process range (e.g., 0-100°C)
2. **Set Output Range**: Configure OUTPUT LOW and OUTPUT HIGH (typically 4-20mA)
3. **Enter Input Value**: Tap the main input field and enter your process value
4. **Read Output**: The calculated output signal is displayed instantly
5. **Quick Calculations**: Use percentage buttons (0%, 25%, 50%, 75%, 100%) for common checkpoints

**Example**: For a temperature transmitter (0-100°C → 4-20mA):
- Input Range: 0 to 100
- Output Range: 4 to 20
- Input Value: 50°C → Output: 12mA

### Positioner Calculator

1. **Sensor mA Range**: Enter the sensor's signal range (typically 4-20mA)
2. **Physical Measurement**: Input actual mA readings at zero and span positions
3. **Desired DCS Range**: Set your target percentage range (e.g., -0.5% to 99.5%)
4. **DCS Setting**: Read the calculated zero and span values for DCS configuration
5. **Zone Indicators**: Monitor zero and span zones for optimal calibration

**Example**: Valve positioner calibration:
- Physical Zero: 5.5mA at fully closed position
- Physical Span: 18.5mA at fully open position
- Desired Range: -0.5% to 99.5%
- Result: DCS settings for 0% and 100% positions

## 🛠️ Technical Stack

**Framework & Language**:
- [Flutter](https://flutter.dev) - Cross-platform mobile framework
- Dart 3.10.4+ - Programming language

**Key Dependencies**:
- `google_mobile_ads` (^5.3.0) - AdMob integration for banner ads
- `shared_preferences` (^2.3.5) - Local data persistence
- `cupertino_icons` (^1.0.8) - iOS-style icons

**Development Tools**:
- `flutter_lints` (^6.0.0) - Dart code analysis and linting

## 🏗️ Architecture

```
lib/
├── main.dart                          # App entry point and theme configuration
├── screens/
│   ├── home_screen.dart              # Main screen with tab navigation
│   ├── loop_calculator_screen.dart   # Loop calculation UI and logic
│   └── positioner_calculator_screen.dart  # Positioner calculation UI and logic
├── widgets/
│   ├── keypad.dart                   # Custom numeric keypad component
│   └── bar_graph.dart                # Visual percentage bar display
└── services/
    └── ad_service.dart               # AdMob integration service
```

## 🎨 Design Philosophy

- **Field-Ready**: Dark theme reduces eye strain in various lighting conditions
- **Single-Hand Operation**: Compact layout designed for mobile use
- **Professional Aesthetic**: Gradient accents and clean typography
- **No Clutter**: Focused interface with only essential controls
- **Instant Feedback**: Real-time calculations and visual indicators

## 📋 Roadmap

- [ ] iOS version support
- [ ] Additional calculator types (Temperature, Pressure conversions)
- [ ] Calculation history and favorites
- [ ] Export/share calculation results
- [ ] Multi-language support
- [ ] Offline documentation

## 🔧 Development

### Project Structure Conventions

- **State Management**: StatefulWidget with local state
- **Theming**: Material Design 3 with custom dark color scheme
- **Code Style**: Following Flutter/Dart official style guide
- **Testing**: Widget tests in `test/` directory

### Color Palette

- Primary: `#00D4FF` (Cyan)
- Secondary: `#7C3AED` (Purple)
- Background: `#0A0A0F` (Near black)
- Surface: `#12121A` (Dark gray)
- Card: `#19192A` (Lighter gray)

## 📄 License

This project is private and proprietary. All rights reserved.

## 👤 Author

**lee-minki**
- GitHub: [@lee-minki](https://github.com/lee-minki)
- Email: minki.lee622@gmail.com

## 🙏 Acknowledgments

Built for industrial automation professionals who need reliable, quick calculations in the field. Special consideration given to compact UI design for modern Android devices.

---

Made with Flutter 💙 | Version 1.0.2+4
