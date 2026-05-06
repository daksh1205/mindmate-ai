# MindMate AI 🧠💙

> A mental health support companion app for Indian teens (13–19) — providing AI-powered chat, voice calls, mood tracking, daily wellness tips, and crisis resources.

---

## Table of Contents

1. [About the Project](#about-the-project)
2. [Features](#features)
3. [Software & Technologies Used](#software--technologies-used)
4. [System Architecture](#system-architecture)
5. [Project Structure](#project-structure)
6. [Prerequisites](#prerequisites)
7. [Installation & Setup](#installation--setup)
8. [Running the Application](#running-the-application)
9. [Backend (RAG Pipeline)](#backend-rag-pipeline)
10. [API Keys & Configuration](#api-keys--configuration)
11. [Screens & Navigation Flow](#screens--navigation-flow)
12. [Crisis Safety Features](#crisis-safety-features)
13. [Deployment](#deployment)
14. [Contributing](#contributing)
15. [Disclaimer](#disclaimer)

---

## About the Project

**MindMate AI** is a cross-platform mobile application designed as a safe, anonymous, and always-available mental health companion for teenagers in India. It is **not** a replacement for professional therapy — it is a supportive tool for times when teens need someone to talk to, especially when traditional support is inaccessible, expensive, or intimidating.

The app uses **Google's Gemini AI** for empathetic, teen-friendly conversations and **Bland AI** for real-time voice calls. All conversations are backed by **Firebase** for anonymous authentication and chat persistence.

---

## Features

| Feature | Description |
|---|---|
| **AI Chat** | Real-time text chat with an empathetic AI companion powered by Gemini 2.5 Flash |
| **Voice Calls** | Initiate phone calls to talk with the AI companion via Bland AI |
| **Mood Check-in** | Track daily mood using a visual mood selector on the dashboard |
| **Daily Tips** | Curated wellness tips (breathing, movement, mindfulness, sleep) |
| **Journal Entry** | Placeholder for journaling (UI present) |
| **Profile Setup** | Choose an avatar, set a name/nickname, and select age range |
| **Call History** | View, refresh, and delete past voice call records |
| **Crisis Detection** | Automatic detection of crisis keywords with Indian helpline resources |
| **Privacy-First** | Anonymous Firebase auth, no personal data collected |
| **Dark Mode UI** | Premium dark theme with glassmorphism and smooth animations |

---

## Software & Technologies Used

### Frontend (Mobile App)

| Technology | Version | Purpose |
|---|---|---|
| **Flutter** | SDK ≥ 3.9.2 | Cross-platform mobile framework (Android, iOS, Web, Desktop) |
| **Dart** | (bundled with Flutter) | Programming language |
| **Google Fonts** | ^6.3.3 | Typography — Plus Jakarta Sans font family |
| **Shared Preferences** | ^2.5.4 | Local storage for user profile and call history |
| **intl** | ^0.20.2 | Date/time formatting and localization |
| **http** | ^1.6.0 | HTTP client for REST API calls (Gemini, Bland AI) |
| **flutter_markdown_plus** | ^1.0.7 | Render markdown-formatted AI responses |
| **flutter_inappwebview** | ^6.1.5 | In-app web view support |
| **cached_network_image** | ^3.4.1 | Cached network image loading for avatars |

### Backend Services

| Technology | Purpose |
|---|---|
| **Firebase Core** (^4.5.0) | Firebase SDK initialization |
| **Firebase Auth** (^6.2.0) | Anonymous authentication |
| **Cloud Firestore** (^6.1.3) | Real-time chat message storage |
| **Google Gemini API** (gemini-2.5-flash) | AI chat responses via REST API |
| **Bland AI API** | AI-powered voice phone calls |

### Backend — RAG Pipeline (Python)

| Technology | Purpose |
|---|---|
| **Python 3.x** | Backend language |
| **FastAPI** | High-performance async web framework |
| **Flask** | Alternative lightweight web framework |
| **LangChain** | LLM orchestration and RAG pipeline |
| **FAISS** | Vector similarity search for document retrieval |
| **OpenAI Embeddings** | Text embedding model for vectorization |
| **Google Generative AI (Gemini 2.0 Flash)** | LLM for generating responses |
| **PyPDF** | PDF document loading |
| **tiktoken** | Token counting for text chunking |
| **uvicorn** | ASGI server for FastAPI |
| **python-dotenv** | Environment variable management |

### Development Tools

| Tool | Purpose |
|---|---|
| **Android Studio / VS Code** | IDE |
| **FlutterFire CLI** | Firebase project configuration |
| **Git** | Version control |
| **Firebase Console** | Backend management |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        MindMate AI App                          │
│                     (Flutter / Dart)                            │
├──────────────────────┬──────────────────────────────────────────┤
│   Chat Service       │   Call Service                           │
│   ┌──────────────┐   │   ┌──────────────┐                       │
│   │ Gemini API   │   │   │ Bland AI API │                       │
│   │ (REST)       │   │   │ (REST)       │                       │
│   └──────┬───────┘   │   └──────┬───────┘                       │
│          │           │          │                               │
│          ▼           │          ▼                               │
│   AI Chat Responses  │   Phone Call Initiation                  │
├──────────────────────┴──────────────────────────────────────────┤
│                    Firebase Backend                             │
│   ┌──────────────┐   ┌──────────────────┐                       │
│   │ Firebase Auth│   │ Cloud Firestore  │                       │
│   │ (Anonymous)  │   │ (Chat History)   │                       │
│   └──────────────┘   └──────────────────┘                       │
├─────────────────────────────────────────────────────────────────┤
│               Local Storage (SharedPreferences)                 │
│   ┌──────────────────────────────────────────┐                  │
│   │ User Profile, Call History, Preferences  │                  │
│   └──────────────────────────────────────────┘                  │
├─────────────────────────────────────────────────────────────────┤
│           RAG Backend (Optional — Python)                       │
│   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐        │
│   │ PyPDFLoader  │──▶│ FAISS Index  │──▶│ Gemini LLM   │        │
│   │ (PDF Books)  │   │ (Vectors)    │   │ (Responses)  │        │
│   └──────────────┘   └──────────────┘   └──────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
mindmate_ai/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── firebase_options.dart              # Firebase config (auto-generated)
│   ├── app/
│   │   └── pages/
│   │       ├── welcome_screen.dart        # Onboarding carousel
│   │       ├── privacy_promise_screen.dart # Privacy commitment screen
│   │       ├── profile_setup_screen.dart   # Initial profile creation
│   │       ├── dashboard_screen.dart       # Main dashboard with nav bar
│   │       ├── chat_screen.dart            # AI chat interface
│   │       ├── call_screen.dart            # Voice call interface
│   │       ├── call_details_page.dart      # Individual call details
│   │       ├── recent_activity_page.dart   # Call history list
│   │       ├── daily_tips_screen.dart      # Wellness tips browser
│   │       └── profile_screen.dart         # Profile view/edit
│   └── core/
│       ├── services/
│       │   ├── auth_service.dart               # Firebase anonymous auth
│       │   ├── chat_service.dart                # Gemini AI chat logic
│       │   ├── call_service.dart                # Bland AI voice call logic
│       │   ├── call_history_service.dart         # Call records (local + API)
│       │   ├── firebase_chat_service.dart        # Firestore chat persistence
│       │   └── shared_preferences_service.dart   # Local key-value storage
│       └── utils/
│           ├── colors.dart                # App color palette
│           ├── constants.dart             # API keys and base URLs
│           └── styles.dart                # Typography, borders, shadows
├── protocol-mental-health/               # Python RAG backend
│   ├── main.py                           # FastAPI server with RAG pipeline
│   └── api.py                            # Flask alternative server
├── android/                              # Android platform files
├── ios/                                  # iOS platform files
├── web/                                  # Web platform files
├── macos/                                # macOS platform files
├── windows/                              # Windows platform files
├── linux/                                # Linux platform files
├── test/                                 # Unit/widget tests
├── pubspec.yaml                          # Flutter dependencies
├── pubspec.lock                          # Locked dependency versions
├── analysis_options.yaml                 # Dart linter configuration
├── firebase.json                         # Firebase project config
├── .gitignore                            # Git ignore rules
└── README.md                             # This file
```

---

## Prerequisites

Before running the project, ensure you have the following installed:

| Requirement | Minimum Version | Installation |
|---|---|---|
| **Flutter SDK** | ≥ 3.9.2 | [flutter.dev/docs/get-started](https://flutter.dev/docs/get-started/install) |
| **Dart SDK** | (bundled with Flutter) | Included with Flutter |
| **Android Studio** | Latest | [developer.android.com/studio](https://developer.android.com/studio) |
| **Xcode** (macOS only) | Latest | Mac App Store |
| **Git** | Any | [git-scm.com](https://git-scm.com/) |
| **Python** (for RAG backend) | ≥ 3.8 | [python.org](https://www.python.org/downloads/) |
| **Firebase CLI** | Latest | `npm install -g firebase-tools` |
| **FlutterFire CLI** | Latest | `dart pub global activate flutterfire_cli` |

---

## Installation & Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/daksh1205/mindmate-ai.git
cd mindmate-ai
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Configure API Keys

Create the constants file at `lib/core/utils/constants.dart`:

```dart
class AppSecrets {
  static const String apiKey = '<YOUR_GEMINI_API_KEY>';
  static const String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";
  static const String blandApiKey = '<YOUR_BLAND_AI_API_KEY>';
  static const String blandBaseUrl = "https://api.bland.ai/v1/calls";
}
```

> **Note:** The `constants.dart` file is listed in `.gitignore` to prevent API key leaks. You must create this file manually.

### Step 4: Firebase Setup

The project is pre-configured with Firebase. If you need to reconfigure:

```bash
firebase login
flutterfire configure --project=mindmate-ai-10604
```

This generates/updates `lib/firebase_options.dart` and platform-specific config files.

### Step 5: Verify Installation

```bash
flutter doctor
```

Ensure all checks pass (especially for your target platform).

---

## Running the Application

### Android

```bash
# Connect a device or start an emulator
flutter run
```

### iOS (macOS only)

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

### Web

```bash
flutter run -d chrome
```

### macOS Desktop

```bash
flutter run -d macos
```

### Run in Debug Mode with Hot Reload

```bash
flutter run --debug
```

### Build Release APK (Android)

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

### Build Release IPA (iOS)

```bash
flutter build ios --release
```

---

## Backend (RAG Pipeline)

The `protocol-mental-health/` directory contains an optional Retrieval-Augmented Generation (RAG) backend that enriches AI responses with context from mental health PDF resources.

### Setup

```bash
cd protocol-mental-health

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# or: venv\Scripts\activate  # Windows

# Install dependencies
pip install fastapi uvicorn langchain langchain-community langchain-openai \
            langchain-google-genai faiss-cpu tiktoken pypdf python-dotenv flask
```

### Configure Environment Variables

Create a `.env` file in the `protocol-mental-health/` directory:

```env
OPENAI_API_KEY=<your-openai-api-key>
GOOGLE_API_KEY=<your-google-api-key>
```

### Add PDF Resources

Place your mental health PDF resources in:

```
protocol-mental-health/resources/Anxiety-Help-Book-For-Teens.pdf
```

### Run the FastAPI Server

```bash
python main.py
# Server starts at http://0.0.0.0:8000
```

### Run the Flask Server (Alternative)

```bash
python api.py
# Server starts at http://127.0.0.1:5001
```

### API Endpoint

```
POST /chat
Content-Type: application/json

{
  "message": "I'm feeling really anxious about exams"
}

Response:
{
  "response": "Exam stress is so real 😔 What's the part that's freaking you out the most?"
}
```

---

## API Keys & Configuration

| Service | Key Required | How to Obtain |
|---|---|---|
| **Google Gemini API** | `apiKey` in `constants.dart` | [aistudio.google.com](https://aistudio.google.com/apikey) |
| **Bland AI** | `blandApiKey` in `constants.dart` | [bland.ai](https://www.bland.ai/) — Sign up for API access |
| **Firebase** | Auto-configured | [console.firebase.google.com](https://console.firebase.google.com/) |
| **OpenAI** (RAG backend) | `OPENAI_API_KEY` in `.env` | [platform.openai.com](https://platform.openai.com/api-keys) |

---

## Screens & Navigation Flow

```
Welcome Screen (Onboarding Carousel)
        │
        ▼
Privacy Promise Screen
        │
        ▼
Profile Setup Screen (Avatar, Name, Age Range)
        │
        ▼
Dashboard Screen ─── Bottom Navigation Bar
   │        │        │
   ▼        ▼        ▼
 Home    History   Profile
   │        │
   ├──▶ Chat Screen (AI Text Chat)
   ├──▶ Call Screen (Voice Call)
   ├──▶ Daily Tips Screen
   │        │
   │        ▼
   │    Call Details Page
   │
   └──▶ Journal Entry (Placeholder)
```

### Screen Descriptions

| Screen | File | Description |
|---|---|---|
| **Welcome** | `welcome_screen.dart` | Auto-scrolling onboarding with 3 slides |
| **Privacy Promise** | `privacy_promise_screen.dart` | Privacy commitments (encryption, anonymity, control) |
| **Profile Setup** | `profile_setup_screen.dart` | Avatar picker, name input, age range selector |
| **Dashboard** | `dashboard_screen.dart` | Home hub with mood check-in, chat/call cards, daily tips |
| **Chat** | `chat_screen.dart` | Real-time AI chat with typing indicator, quick-action chips |
| **Call** | `call_screen.dart` | Voice call interface with animated ripple button |
| **Call Details** | `call_details_page.dart` | Detailed view of a call (ID, duration, summary) |
| **Recent Activity** | `recent_activity_page.dart` | Call history with swipe-to-delete |
| **Daily Tips** | `daily_tips_screen.dart` | Filterable wellness tips with expandable cards |
| **Profile** | `profile_screen.dart` | View/edit profile with animated transitions |

---

## Crisis Safety Features

MindMate includes automatic crisis detection:

### Crisis Keywords Monitored

`suicide`, `kill myself`, `end my life`, `want to die`, `self harm`, `cut myself`, `hurt myself`, `no reason to live`, `better off dead`

### Helplines Provided

| Organization | Phone | Availability |
|---|---|---|
| **iCall Psychosocial Helpline** | 9152987821 | Mon–Sat, 8 AM – 10 PM |
| **Vandrevala Foundation** | 1860 2662 345 / 1800 2333 330 | 24/7 |
| **AASRA** | +91 9820466726 | 24/7 |
| **Sneha Foundation (Chennai)** | +91 44 2464 0050 / 0060 | 24/7 |
| **Connecting NGO (Bangalore)** | +91 98453 95659 | — |

When crisis keywords are detected, the AI generates a compassionate response **and** appends all helpline resources.

---

## Deployment

### Firebase Hosting (Web)

```bash
flutter build web
firebase deploy --only hosting
```

### Android (Google Play Store)

```bash
flutter build appbundle --release
# Upload build/app/outputs/bundle/release/app-release.aab to Play Console
```

### iOS (App Store)

```bash
flutter build ios --release
# Use Xcode to archive and upload to App Store Connect
```

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit changes: `git commit -m "Add my feature"`
4. Push to branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## Disclaimer

> **MindMate AI is NOT a replacement for professional mental health support.** It is a supplementary tool designed to provide emotional support and wellness resources. If you or someone you know is in crisis, please contact a mental health professional or call one of the helplines listed above.

---

*Built with 💙 for teens who need someone to talk to.*
