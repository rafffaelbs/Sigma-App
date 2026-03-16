# Sigma App — UFV Inspection & Commissioning Reports

> **Professional PDF report generation for medium-voltage solar farm commissioning.**  
> Built by [Sigma PowerSys](https://sigma-powersys.com.br) · Flutter · Firebase


## Overview

Sigma App is a Flutter mobile application that streamlines the commissioning workflow for solar farms (UFV — *Usina Fotovoltaica*). Field engineers use it to capture measurement readings, attach photos, and instantly generate branded, publication-ready PDF inspection reports — entirely from a mobile device.

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
- Firebase Storage for photo uploads
- Local persistence via `shared_preferences` for full offline capability

### 📷 Photo & Location Documentation
- In-app camera capture and gallery picker
- GPS tagging for each inspection site

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.10.3+ / Dart |
| Backend | Firebase (Firestore, Storage) |
| PDF Engine | `pdf ^3.11.3`, `printing ^5.14.2` |
| Image Handling | `image_picker`, `gal`, `camera` |
| Geolocation | `geolocator ^14.0.2` |
| Local Storage | `shared_preferences ^2.5.4` |

---

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # UI screens
├── services/
│   └── pdf_service.dart      # PDF report generation
├── models/
│   ├── plant_model.dart      # UFV / plant data models
│   └── measurements.dart     # Measurement data models
└── widgets/                  # Reusable UI components
```

---

## Getting Started

### Prerequisites

- Flutter SDK **3.10.3** or higher ([install guide](https://docs.flutter.dev/get-started/install))
- A configured Firebase project
- A `.env` file with your Firebase credentials (see [Configuration](#configuration))

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

3. **Configure Firebase** — see [Configuration](#configuration) below

4. **Run the app**
   ```bash
   flutter run
   ```

---

## Configuration

Create a `.env` file in the project root with your Firebase credentials:

```env
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
```

---

## Generating a Report

1. Select or create a UFV (solar farm) in the app
2. Fill in project data and transformer details
3. Record measurements for each instrument
4. Attach photos from camera or gallery
5. Tap **Generate Report** — the app renders a PDF and triggers the native share/save dialog