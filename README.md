# ⚙️ Calibration Calculator

Professional instrumentation calibration tools for field engineers and technicians working with industrial control systems and sensors.

> **Multi-Platform Solution**: Available as both a native Flutter mobile app and a Progressive Web App (PWA)

## 🎯 Overview

Calibration Calculator provides essential calculation tools for process control instrumentation:

- **Loop Calculator**: Convert values between input/output ranges (4-20mA signal scaling)
- **Positioner Calculator**: Calculate DCS (Distributed Control System) settings for valve positioner calibration

## 📱 Choose Your Version

This monorepo contains two implementations of the Calibration Calculator:

### 🚀 [Flutter Version](./flutter) - Recommended for Mobile

**Native mobile app** built with Flutter for Android devices.

**Features**:
- Native performance and offline capability
- Dark theme optimized for field conditions
- Custom numeric keypad with haptic feedback
- AdMob integration
- Portrait-only orientation lock
- Optimized for Galaxy S24/S25

**Latest Release**: v1.0.2

**Installation**:
- Download from [GitHub Releases](https://github.com/lee-minki/Calibration-Calculator-Flutter/releases)
- Supports Android 5.0+

[→ View Flutter Documentation](./flutter/README.md)

---

### 🌐 [PWA/TWA Version](./twa)

**Progressive Web App** that works in any modern browser.

**Features**:
- Cross-platform (works on any device with a web browser)
- No installation required - use directly from browser
- Installable as standalone app
- Service Worker for offline support
- Lightweight and fast

**Status**: v1.0.0 (Stable)

**Usage**:
- Access via web browser
- Can be installed as PWA on mobile devices
- Also available as TWA (Trusted Web Activity) for Android

[→ View PWA Documentation](./twa/README.md)

---

## 🔄 Feature Comparison

| Feature | Flutter | PWA/TWA |
|---------|---------|---------|
| **Platform** | Android (native) | Any browser |
| **Installation** | APK/AAB download | Browser or install as PWA |
| **Performance** | Native (faster) | Web-based |
| **Offline Mode** | ✅ Full | ✅ Service Worker |
| **App Size** | ~40MB | <100KB |
| **Updates** | Manual download | Automatic |
| **Haptic Feedback** | ✅ | Limited |
| **AdMob Ads** | ✅ | ❌ |
| **Best For** | Daily field use | Quick access, cross-platform |

## 🛠️ Core Calculations

Both versions provide identical calculation capabilities:

### Loop Calculator
Converts process values to standard output signals:
- Configurable input/output ranges
- Quick percentage calculations (0%, 25%, 50%, 75%, 100%)
- Real-time visual feedback
- Support for decimal precision

**Example**: Temperature transmitter (0-100°C → 4-20mA)
- Input: 50°C → Output: 12mA

### Positioner Calculator
Determines DCS settings for valve positioners:
- Physical measurement input
- Desired DCS range configuration
- Zero/Span zone visualization (-5% to 5%, 95% to 105%)
- Real-time DCS setting calculation

**Example**: Valve positioner calibration
- Physical readings: 5.5mA (zero), 18.5mA (span)
- Desired range: -0.5% to 99.5%
- Result: Calculated DCS settings

## 🏗️ Repository Structure

```
calibration-calculator/
├── flutter/                  # Flutter mobile app (Android primary, iOS scaffolded)
│   ├── lib/                 # Dart source code
│   ├── android/             # Android platform code
│   │   └── app/
│   │       ├── build.gradle.kts        # env-var-aware signing config
│   │       ├── key.properties.example  # local-dev template
│   │       └── proguard-rules.pro      # R8 rules (AdMob + Flutter)
│   ├── ios/                 # iOS platform code (future)
│   ├── assets/icon/         # Master PNGs for flutter_launcher_icons
│   └── README.md            # Flutter-specific documentation
│
├── twa/                     # Progressive Web App / TWA source
│   ├── index.html           # Markup + iOS PWA meta
│   ├── app.js               # Logic + SW registration
│   ├── styles.css           # Dark design system
│   ├── sw.js                # Service Worker (BUILD_TAG cache busting)
│   ├── manifest.json        # PWA manifest with shortcuts/maskable
│   ├── privacy.html         # Privacy Policy (en + ko)
│   ├── icons/               # SVG sources + PNG outputs
│   ├── .well-known/
│   │   └── assetlinks.json  # Digital Asset Links for TWA
│   └── README.md            # PWA-specific documentation
│
├── docs/
│   └── play-store/          # Store-listing assets
│       ├── listing-en.md            # title/short/full description (English)
│       ├── listing-ko.md            # 등록정보 (한국어)
│       ├── data-safety.md           # Play Console Data Safety answers
│       ├── feature-graphic.svg      # Source 1024×500
│       └── feature-graphic.png      # Renderable PNG for Play Console
│
├── scripts/
│   ├── release.sh           # one-shot AAB+APK build
│   └── bump-version.sh      # patch/minor/major version bump + git tag
│
├── .github/workflows/
│   ├── flutter-ci.yml       # format/analyze/test on PR
│   ├── flutter-release.yml  # AAB/APK on tag push + GitHub Release
│   └── pwa-deploy.yml       # GitHub Pages deploy on twa/** push
│
└── README.md                # This file
```

## 🚢 Release flow

```bash
./scripts/bump-version.sh patch       # 1.0.2+4 → 1.0.3+5, commits + tags
git push && git push --tags           # Triggers Flutter release workflow
```

The release workflow builds + signs the AAB, uploads it as a workflow
artifact, and (on tag push) attaches the AAB/APK to a GitHub Release.
Upload the AAB to Play Console manually for review.

See `docs/play-store/` for the listing text, data-safety answers, and the
feature graphic ready for upload.

## 🚀 Quick Start

### For End Users

**Mobile (Android)**:
1. Download the latest Flutter APK from [Releases](https://github.com/lee-minki/Calibration-Calculator-Flutter/releases)
2. Install on your Android device
3. Launch and start calculating

**Web/Any Device**:
1. Open your browser
2. Navigate to the deployed PWA URL (see [twa/README.md](./twa/README.md))
3. Use directly or install as app

### For Developers

**Flutter Version**:
```bash
cd flutter/
flutter pub get
flutter run
```

**PWA Version**:
```bash
cd twa/
# Serve with any static file server
python -m http.server 8000
# Or use Live Server in VS Code
```

## 📖 Documentation

- [Flutter App Documentation](./flutter/README.md) - Detailed Flutter app guide
- [PWA Documentation](./twa/README.md) - Web app deployment and usage

## 🎨 Design Philosophy

Both versions share a consistent design language:

- **Dark Theme**: Optimized for various lighting conditions
- **Professional Aesthetic**: Clean, focused interface
- **Field-Ready**: Designed for real-world industrial environments
- **Intuitive**: Minimal learning curve for engineers

## 📋 Version History

### Flutter
- **v1.0.2** (2024-12-19): Compact layout for Galaxy S24/S25
- **v1.0.1**: AdMob integration
- **v1.0.0**: Initial release

### PWA/TWA
- **v1.0.0**: Initial release with core calculations

## 👤 Author

**lee-minki**
- GitHub: [@lee-minki](https://github.com/lee-minki)
- Email: minki.lee622@gmail.com

## 📄 License

This project is private and proprietary. All rights reserved.

## 🙏 Acknowledgments

Built for industrial automation professionals who need reliable, quick calculations in the field. Designed with input from process engineers and instrument technicians.

---

**Choose the version that best fits your needs** - native mobile performance or cross-platform flexibility!
