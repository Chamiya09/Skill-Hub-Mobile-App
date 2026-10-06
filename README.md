# Skill Hub — Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg)](https://dart.dev/)
[![Android](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-3DDC84.svg)](https://developer.android.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

The mobile companion application for **Skill Hub**, developed using **Flutter**. Designed specifically for job seekers (candidates) and mobile recruiters, offering on-the-go notifications, profile management, and interview calendar synchronization.

---

## 🌟 Component Overview & Responsibilities

- **Job Exploration:** Search, filter, and save active job vacancies with a responsive mobile interface.
- **One-Tap Apply:** Submit digital applications using stored candidate CV credentials.
- **Interview Notifications:** Native calendar synchronization and push notifications for upcoming interview slots.
- **Application Status Tracker:** Real-time visibility into whether applications are `Screened`, `Shortlisted`, or `Selected`.

---

## 🛠️ Technology Stack & Core Dependencies

- **Framework:** Flutter 3.x (with Dart 3.x)
- **State Management:** Provider / BLoC
- **Networking:** `http` / `dio` (with JWT Bearer interceptors)
- **Local Storage:** `flutter_secure_storage` / `shared_preferences` (encrypted auth token storage)
- **Device Features:** Native date/time pickers and calendar synchronization

---

## 📋 Prerequisites

- **Flutter SDK:** `^3.22.0` (Verify using `flutter doctor`)
- **Dart SDK:** `^3.4.0`
- **Android Studio / Xcode:** For emulator setup and platform compilation
- **Java Development Kit (JDK):** Version 17

---

## 🚀 Quickstart & Local Setup

### 1. Clone Repository
```bash
git clone https://github.com/Chamiya09/Skill-Hub-Mobile-App.git
cd Skill-Hub-Mobile-App
```

### 2. Configure Environment (.env)
Create a `.env` file in the root directory:
```env
# Backend API Base URL
API_BASE_URL=<ENTER_BACKEND_API_URL> # e.g. http://10.0.2.2:5155/api for Android Emulator or your server URL
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run on Connected Device / Emulator
```bash
# List available devices/emulators
flutter devices

# Launch debug session
flutter run
```

---

## 📦 Building Production Binaries

### Android APK Build
To generate an installable Android Application Package (APK):
```bash
# Debug APK
flutter build apk --debug

# Optimized Release APK
flutter build apk --release
```
The compiled binary will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### Manual Device Installation
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Testing & Code Quality

```bash
# Run unit and widget test suite
flutter test

# Perform static code analysis
flutter analyze
```