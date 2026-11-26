# Skill Hub — Cross-Platform Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-3DDC84.svg)](https://flutter.dev/)
[![Security](https://img.shields.io/badge/Security-Encrypted%20Storage-blueviolet.svg)](https://pub.dev/packages/flutter_secure_storage)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

The mobile companion application for **Skill Hub** — an enterprise AI-driven Applicant Tracking System (ATS), talent marketplace, and technical assessment platform. Engineered with **Flutter** and **Dart**, this cross-platform client delivers a fluid, responsive mobile experience for Job Seekers (Candidates) and Hiring Managers to explore jobs, monitor application lifecycles, access AI interview guides, and synchronize interview schedules on the go.

---

## 📑 Table of Contents

- [🌟 Features & Capabilities](#-features--capabilities)
- [📱 Mobile Architecture & Design Pattern](#-mobile-architecture--design-pattern)
- [🛠️ Technology Stack & Dependencies](#️-technology-stack--dependencies)
- [📂 Repository Structure](#-repository-structure)
- [📋 Prerequisites](#-prerequisites)
- [🚀 Quickstart & Local Setup](#-quickstart--local-setup)
- [⚙️ Environment Configuration](#️-environment-configuration)
- [📦 Building Production Binaries (Android APK)](#-building-production-binaries-android-apk)
- [🧪 Testing & Code Quality](#-testing--code-quality)
- [🔒 Security & Storage Architecture](#-security--storage-architecture)
- [📄 License](#-license)

---

## 🌟 Features & Capabilities

- **Authentication & Secure Auto-Login:** Seamless candidate sign-in backed by encrypted hardware keystore token persistence and proactive session restoration.
- **Job Discovery & Search:** Real-time vacancy exploration with dynamic keyword search, department filtering, employment type tags, and salary visibility.
- **Company Profile Showcase:** In-depth company dossiers with verified badges, corporate bio, company size, website links, and active vacancies.
- **One-Tap Job Applications:** Instant application submissions using the candidate's existing digital CV profile with optional cover notes.
- **Saved Jobs & Bookmarks:** Offline-ready personal bookmark manager allowing candidates to curate target positions.
- **Application Status Hub:** End-to-end transparency across all application stages:
  - 🟡 `Applied` — Application submitted and pending review.
  - 🔵 `Screened` — Resume processed and evaluated by AI match agent.
  - 🟣 `Shortlisted` — Candidate selected for technical coding assessment.
  - 🟢 `Selected` — Advanced to formal interview rounds.
  - 🔴 `Rejected` — Application concluded.
- **Assessment Results Viewer:** Mobile view of assigned coding exams, deadlines, proctored submission status, and final weighted scores.
- **Interview Hub & Meeting Links:** Real-time interview calendar with dates, times, meeting modes (Remote / On-site), and direct video conference links.
- **AI Interview Preparation on Mobile:** Instant on-the-go access to AI-generated study guidelines, behavioral interview questions, and role-specific preparation checklists.
- **Digital CV Management:** Direct mobile inspection and editing of candidate experience, education, verified skills, and portfolio links.

---

## 📱 Mobile Architecture & Design Pattern

The application adopts a modular, service-oriented architecture with clean separation between UI components, view controllers, domain models, and network services:

```
+─────────────────────────────────────────────────────────────+
|               Skill Hub Mobile Architecture                 |
+─────────────────────────────────────────────────────────────+
                               |
                        [ AuthGate ]
                               |
            +──────────────────┴──────────────────+
            |                                     |
    [ Unauthenticated ]                    [ Authenticated ]
            |                                     |
[ CandidateLoginScreen ]             [ CandidateMainScaffold ]
                                                  |
     +──────────────────+──────────────────+──────┴───────────+──────────────────+
     |                  |                  |                  |                  |
[ HomeScreen ]   [ FindJobsScreen ] [ Applications ]   [ InterviewsScreen ] [ DigitalCvScreen ]
     |                  |                  |                  |                  |
     +──────────────────+──────────────────+──────────────────+──────────────────+
                               |
                               v
                     +───────────────────+
                     |  Domain Services  |
                     |  - PublicJobs     |
                     |  - Applications   |
                     |  - Assessments    |
                     |  - Interviews     |
                     |  - Digital CV     |
                     |  - Interview Prep |
                     +───────────────────+
                               |
                               v
                     +───────────────────+
                     |    ApiService     |
                     | (JWT Interceptor) |
                     +───────────────────+
                               |
            +──────────────────┴──────────────────+
            |                                     |
            v                                     v
  [ Secure Storage ]                    [ REST API Backend ]
  - Android Keystore                    - ASP.NET Core 8 Web API
  - iOS Keychain                        (Bearer Authorization)
```

---

## 🛠️ Technology Stack & Dependencies

| Category | Package / Tool | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **Framework** | Flutter SDK | `>=3.10.0 <4.0.0` | Cross-platform mobile UI development framework |
| **Language** | Dart SDK | `^3.x` | Strongly typed object-oriented client language |
| **Networking** | `http` | `^1.5.0` | HTTP communication with backend REST API |
| **Secure Storage** | `flutter_secure_storage`| `^9.2.4` | Hardware-backed encrypted key-value token storage |
| **Environment** | `flutter_dotenv` | `^6.0.1` | Loads configuration variables from `.env` asset file |
| **UI Components** | `cupertino_icons` | `^1.0.8` | iOS style icons alongside Material Design widgets |
| **Static Analysis**| `flutter_lints` | `^6.0.0` | Official idiomatic Dart and Flutter lint rules |

---

## 📂 Repository Structure

```
Skill-Hub-Mobile-App/
├── .github/
│   └── workflows/
│       └── flutter-ci.yml          # Automated Flutter build & analyze CI workflow
├── android/                        # Native Android Gradle configuration and manifests
├── ios/                            # Native iOS Xcode workspace and CocoaPods specs
├── lib/
│   ├── components/                 # Reusable UI widgets
│   │   ├── company_logo_button.dart# Avatar and company badge component
│   │   └── skill_hub_loading_indicator.dart # Branded loading animation
│   ├── config/                     # Application-wide configuration
│   │   └── api_config.dart         # Resolves backend API endpoints from environment
│   ├── models/                     # Strongly typed data transfer objects (DTOs)
│   │   ├── auth_session.dart       # User authentication token and role model
│   │   ├── candidate_application.dart # Job application status and metadata model
│   │   ├── candidate_assessment.dart  # Coding exam assignments and scores model
│   │   ├── candidate_interview.dart   # Interview events and meeting links model
│   │   ├── company_profile.dart    # Employer profile model
│   │   ├── job.dart                # Job vacancy details model
│   │   └── saved_job.dart          # Bookmarked job model
│   ├── screens/                    # User interface screens
│   │   ├── auth/                   # Authentication flow
│   │   │   ├── auth_gate.dart      # Dynamic route switcher based on session state
│   │   │   ├── candidate_login_screen.dart # Candidate sign-in interface
│   │   │   └── loading_screen.dart # Splash and token initialization screen
│   │   └── candidate/              # Authenticated candidate portal views
│   │       ├── applied_jobs_screen.dart    # Application lifecycle timeline
│   │       ├── assessments_screen.dart     # Assigned coding exams and scores
│   │       ├── candidate_home_screen.dart  # Quick actions, stats & overview
│   │       ├── candidate_main_scaffold.dart# Bottom navigation bar controller
│   │       ├── company_details_screen.dart # Detailed company bio and openings
│   │       ├── digital_cv_screen.dart      # Mobile CV editor and skill manager
│   │       ├── find_jobs_screen.dart       # Vacancy search and filter browser
│   │       ├── interviews_screen.dart      # Interview schedule and join buttons
│   │       ├── job_view_screen.dart        # Full job spec and one-tap application
│   │       └── saved_jobs_screen.dart      # Saved vacancy collection
│   ├── services/                   # Business logic and network clients
│   │   ├── api_service.dart        # Core HTTP client with JWT injection
│   │   ├── auth_service.dart       # Sign-in, sign-out, session restoration
│   │   ├── auth_storage.dart       # Abstract secure storage contract
│   │   ├── auth_storage_factory.dart # Platform factory (Native vs Web)
│   │   ├── auth_storage_native.dart# Android Keystore / iOS Keychain driver
│   │   ├── auth_storage_web.dart   # Browser localStorage driver
│   │   ├── candidate_applications_service.dart # Application submissions & history
│   │   ├── candidate_assessments_service.dart  # Assessment listing & score queries
│   │   ├── candidate_cv_service.dart           # CV portfolio CRUD operations
│   │   ├── candidate_interviews_service.dart   # Interview timetable client
│   │   ├── company_profile_service.dart        # Company profile fetcher
│   │   ├── interview_prep_service.dart         # AI interview guide client
│   │   ├── public_jobs_service.dart            # Vacancy catalog search client
│   │   └── saved_jobs_service.dart             # Job bookmarking client
│   └── main.dart                   # Application entry point & environment initialization
├── test/                           # Unit and widget test suite
├── .env                            # Active environment configuration (git ignored)
├── .env.example                    # Template environment file
├── analysis_options.yaml           # Lint analyzer configuration
└── pubspec.yaml                    # Flutter project dependencies, assets & metadata
```

---

## 📋 Prerequisites

Ensure your development environment meets the following requirements:

- **Flutter SDK:** Version `3.22.x` or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK:** Version `3.4.x` or higher (bundled with Flutter)
- **Java Development Kit (JDK):** Version 17
- **Android Studio / Android SDK:** For Android emulator and APK compilation
- **Xcode & CocoaPods:** (macOS only) For iOS simulator and IPA builds

Verify your setup using the Flutter diagnostic tool:
```bash
flutter doctor
```

---

## 🚀 Quickstart & Local Setup

### 1. Clone the Repository
```bash
git clone https://github.com/Chamiya09/Skill-Hub-Mobile-App.git
cd Skill-Hub-Mobile-App
```

### 2. Configure Environment (`.env`)
Create a `.env` file in the root of the mobile project:
```bash
cp .env.example .env
```
Populate `.env` with your backend API URL:
```env
# Point to your backend REST API:
# For Android Emulator accessing local host machine: http://10.0.2.2:5155/api
# For iOS Simulator: http://localhost:5155/api
# For Physical Device: http://<YOUR_LOCAL_IP>:5155/api
# For Cloud Production Backend: https://ca-skillhub-backend.bravebay-18c4a18e.eastasia.azurecontainerapps.io/api
API_BASE_URL=http://10.0.2.2:5155/api
```

*(Note: The `.env` file is declared as an asset in `pubspec.yaml` and loaded via `dotenv.load()` on app initialization).*

### 3. Fetch Flutter Dependencies
```bash
flutter pub get
```

### 4. Run on Connected Device / Emulator
```bash
# Check connected devices and emulators
flutter devices

# Launch the app in debug mode
flutter run
```

---

## ⚙️ Environment Configuration

| Variable | Required | Default | Description |
| :--- | :---: | :--- | :--- |
| `API_BASE_URL` | **Yes** | — | Target Skill Hub ASP.NET Core API root with trailing slash (e.g. `http://10.0.2.2:5155/api/`). |

---

## 📦 Building Production Binaries (Android APK)

To compile an installable standalone Android package:

### 1. Clean Build Cache
```bash
flutter clean
flutter pub get
```

### 2. Build Release APK
```bash
# Build universal optimized release APK
flutter build apk --release

# Or build split per-ABI APKs (smaller file sizes for arm64-v8a, armeabi-v7a, x86_64)
flutter build apk --release --split-per-abi
```

The compiled release package will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 3. Sideload APK onto Device via ADB
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Testing & Code Quality

```bash
# Run all unit and widget tests
flutter test

# Run static code analysis according to analysis_options.yaml
flutter analyze
```

---

## 🔒 Security & Storage Architecture

- **Encrypted Token Vault:** Uses `flutter_secure_storage` to safeguard candidate JWT Bearer credentials.
  - **Android:** Uses the Android Keystore provider with encrypted shared preferences (AES-256 GCM).
  - **iOS:** Uses Apple Keychain services with `kSecAttrAccessibleAfterFirstUnlock`.
- **Platform Factory Pattern:** `auth_storage_factory.dart` dynamically switches between native hardware-backed storage and web localStorage, ensuring seamless compilation across platforms without conditional runtime crashes.
- **Stateless Bearer Injection:** `ApiService` intercepts outbound HTTP calls, attaching `Authorization: Bearer <token>` automatically, and invokes `AuthGate` navigation reset whenever a `401 Unauthorized` is returned.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
