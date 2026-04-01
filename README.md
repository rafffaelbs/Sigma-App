# Sigma App — UFV Inspection & Commissioning Reports

> **Professional PDF report generation for medium-voltage solar farm commissioning.**  
> Built by [Sigma PowerSys](https://sigma-powersys.com.br) · Flutter · Firebase · Supabase


## Overview

Sigma App is a Flutter mobile application that streamlines the commissioning workflow for solar farms (UFV — *Usina Fotovoltaica*). Field engineers use it to capture measurement readings, attach photos, and instantly generate branded, publication-ready PDF inspection reports — entirely from a mobile device.

Data is synced to the cloud via Firebase Firestore and photos/PDFs are stored in Supabase Storage, with full offline support for fieldwork in areas with no connectivity.

---

## Features

### 📄 PDF Report Generation
Produces multi-section, branded reports covering all commissioning phases, including cover page, transformer data, inspection tables, measurement readings, and photo documentation.

### 🔬 Six Electrical Measurement Instruments

| Instrument | Measurement |
|---|---|
| **Megôhmetro** | Insulation resistance |
| **Microohmímetro** | Low resistance / contact resistance |
| **TTR** | Transformer turns ratio |
| **Hipot** | Dielectric strength |
| **Terrômetro** | Ground / earth resistance |
| **Toque e Passo** | Step & touch voltage potential |

### ☁️ Cloud & Offline Support
- Firebase Firestore for real-time data sync
- Supabase Storage for photo and PDF uploads
- Local persistence via `shared_preferences` for full offline capability
- Automatic sync when connectivity is restored (`local_sync_service`)

### 📷 Photo & Location Documentation
- In-app camera capture and gallery picker
- GPS tagging for each inspection site

### 🔐 Authentication
- Firebase Authentication for secure, role-based access

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.10.3+ / Dart |
| Auth & Database | Firebase Auth, Cloud Firestore |
| File Storage | Supabase Storage (images & PDFs) |
| PDF Engine | `pdf ^3.11.3`, `printing ^5.14.2` |
| Image Handling | `image_picker`, `gal`, `camera` |
| Geolocation | `geolocator ^14.0.2` |
| Local Storage | `shared_preferences ^2.5.4` |

---

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── firebase_options.dart          # Firebase platform configuration
├── screens/                       # UI screens
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── select_plant.dart
│   ├── select_ufv.dart
│   ├── edit_ufv.dart
│   └── ufv_instrument_screen.dart
├── services/
│   ├── pdf_service.dart           # PDF report generation
│   ├── supabase_service.dart      # Image & PDF cloud storage
│   ├── upload_service.dart        # Upload orchestration
│   ├── local_sync_service.dart    # Offline sync logic
│   ├── plant_service.dart         # Plant CRUD operations
│   └── evaluation_service.dart    # Measurement evaluation logic
├── models/
│   ├── plant_model.dart           # UFV / plant data models
│   └── measurements.dart          # Measurement data models
└── widgets/                       # Reusable UI components
```

---

## Getting Started

### Prerequisites

- Flutter SDK **3.10.3** or higher ([install guide](https://docs.flutter.dev/get-started/install))
- A configured Firebase project ([Firebase Console](https://console.firebase.google.com))
- A configured Supabase project ([Supabase Dashboard](https://supabase.com/dashboard))
- A `.env` file with your credentials (see [Configuration](#configuration) below)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/sigma-app.git
   cd sigma-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure credentials** — see [Configuration](#configuration) below

4. **Run the app**
   ```bash
   flutter run
   ```

---

## Configuration

Create a `.env` file in the project root with the following keys:

```env
# Firebase — Android API key (from google-services.json)
ANDROID_API_KEY=your_android_api_key

# Firebase — iOS API key (from GoogleService-Info.plist)
IOS_API_KEY=your_ios_api_key

# Supabase project URL
SUPABASE_URL=https://your-project-id.supabase.co

# Supabase anon/public key
SUPABASE_ANON_KEY=your_supabase_anon_key
```

> **Note:** The `.env` file is listed in `.gitignore` and must **never** be committed to version control.

### Firebase Setup

1. Create a Firebase project and register your Android & iOS apps
2. Enable **Cloud Firestore** and **Firebase Authentication**
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) — these are also gitignored and must be added locally

### Supabase Setup

1. Create a Supabase project and note your project URL and anon key
2. Create two storage buckets: `images` and `reports`
3. Configure Row Level Security (RLS) policies to restrict access appropriately

---

## Generating a Report

1. Select or create a UFV (solar farm) in the app
2. Fill in project data and transformer details
3. Record measurements for each instrument
4. Attach photos from camera or gallery
5. Tap **Generate Report** — the app renders a PDF and triggers the native share/save dialog
6. The PDF is automatically uploaded to Supabase Storage for cloud archiving

---

## License

This project is proprietary software developed by [Sigma PowerSys](https://sigma-powersys.com.br). All rights reserved.

---

## Contact

**Sigma PowerSys**  
🌐 [sigma-powersys.com.br](https://sigma-powersys.com.br)