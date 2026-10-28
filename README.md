# Visitor Management App

A Flutter mobile application designed for front desk staff and security teams to streamline visitor check-ins, register guest passes, generate downloadable QR codes, verify badges via camera scanning, and track visitor statistics across facilities.

---

## 1. Project Overview

The Visitor Management application simplifies visitor workflows in residential and corporate facilities:
- **Fast Registration**: Captures visitor profile details (name, phone, email, project, visit category, and purpose).
- **Badge & QR Issuance**: Automatically creates digital visitor passes with clear human-readable details and downloadable QR codes saved directly to the device's Downloads folder.
- **Instant Check-In / Check-Out**: Security guards can scan visitor QR badges with the camera scanner to verify visitor ID and current status, immediately checking visitors in or out.
- **Analytics & Reporting**: Tracks daily and weekly visitor metrics, including checked-in vs. checked-out trends and breakdown by visitor type (Customer, Vendor, Other).
- **Offline Resiliency**: Built with an offline-first architecture using local caching with SharedPreferences fallback, ensuring uninterrupted operation during network outages.

---

## 2. Flutter & Dart Version

The application was developed and verified against the following stable environment:

- **Flutter SDK**: `3.44.4` (Channel stable)
- **Dart SDK**: `3.12.2`
- **Target Platforms**: Android (minSdkVersion 21, targetSdkVersion 34), iOS (iOS 12.0+)

---

## 3. Application Features

- **Front Desk Authentication**: Security desk login with validation rules (minimum length, uppercase letter, number, and special character requirements).
- **Dashboard & Quick Actions**: Real-time counter metrics for Total Visitors Today, Currently Checked In, and Checked Out Today, with quick access buttons to register, list, and scan.
- **Visitor Registration**: Form with full validation for 10-digit mobile numbers, unique ID generation (`VST001`, `VST002`, ...), visitor categories (Customer, Vendor, Other), and project assignments.
- **Interactive Visitor List**:
  - Search by visitor name or mobile number.
  - Filter by project or status (Registered, Checked In, Checked Out).
  - Pull-to-refresh data sync.
  - Custom empty-state illustration when no visitor records exist.
- **Visitor Details & QR Pass**:
  - Displays full visitor profile with formatted registration and check-in/out timestamps.
  - Generates a human-readable QR code containing visitor ID, status, and visitor details.
  - One-tap download to device Downloads folder (`/storage/emulated/0/Download/`).
- **Camera QR Scanner**:
  - Real-time barcode detection powered by `mobile_scanner`.
  - Automatically extracts visitor ID from plain text, labeled passes (`Extract the visitor ID : VST001`), JSON, or deep links.
  - Retrieves live visitor status from the API/repository.
  - Validates badge authenticity and displays an alert dialog on invalid or unregistered codes.
  - Manual ID entry fallback when camera access is restricted.
- **Scanned Visitor Screen**:
  - Prominently displays the extracted visitor ID and current status.
  - Shows complete visitor profile information.
  - One-tap buttons for Check In and Check Out status updates.
- **Visitor Statistics & Weekly Trends**:
  - Interactive date picker (calendar view) allowing staff to select any date.
  - Weekly Monday-to-Sunday bar chart comparing Checked In vs. Checked Out activity.
  - Synchronized visitor type donut chart breaking down Customer, Vendor, and Other visitors for the selected week.

---

## 4. State Management Approach

The application uses the **BLoC (Business Logic Component)** pattern (`flutter_bloc` v8.1.6) combined with `equatable` to ensure predictable, unidirectional data flow and clean separation between UI and business logic.

### BLoC Structure

- **`AuthBloc`**:
  - **Events**: `LoginSubmitted`, `LogoutRequested`, `CheckAuthStatus`.
  - **States**: `AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthFailure`.
  - Manages front desk credentials and session persistence via `SharedPreferences`.

- **`VisitorBloc`**:
  - **Events**: `LoadVisitors`, `RegisterVisitorSubmitted`, `UpdateVisitorSubmitted`, `CheckInVisitorRequested`, `CheckOutVisitorRequested`, `DeleteVisitorRequested`, `SearchVisitors`, `FilterVisitors`, `ScanVisitorRequested`, `SelectVisitor`.
  - **States**: `VisitorInitial`, `VisitorLoading`, `VisitorLoaded`, `VisitorError`.
  - Manages visitor list, query filters, repository coordination, QR parsing, and optimistic UI updates.

### Unidirectional Data Flow

```
UI (Widgets / Screens)
   │
   ▼ Dispatches Event
BLoC (Business Logic)
   │
   ▼ Calls Repository
Repository (Local Cache + Mock REST API)
   │
   ▲ Emits Immutable State
UI (BlocBuilder / BlocConsumer re-renders)
```

---

## 5. Packages and Dependencies

| Package | Version | Purpose |
| :--- | :--- | :--- |
| `flutter_bloc` | `^8.1.6` | Predictable state management with BLoC pattern |
| `equatable` | `^2.0.5` | Value-based equality for states and models without boilerplate |
| `mobile_scanner` | `^6.0.4` | High-performance native camera QR and barcode scanner |
| `qr_flutter` | `^4.1.0` | Vector and raster QR code generation |
| `http` | `^1.2.2` | REST API communication over HTTP/HTTPS |
| `shared_preferences` | `^2.3.2` | Persistent key-value storage for offline cache and auth session |
| `intl` | `^0.19.0` | Date formatting and localized timestamp display |
| `uuid` | `^4.5.1` | Unique ID generation support |
| `cupertino_icons` | `^1.0.8` | Standard iOS style icons |

---

## 6. Setup and Execution Instructions

### Prerequisites

- Flutter SDK (v3.44.4 or compatible 3.x)
- Dart SDK (v3.12.2 or compatible 3.x)
- Android Studio / VS Code with Flutter extension
- Connected physical device or emulator (Android 8.0+ recommended)

### Step-by-Step Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd visitor_mangement_app
   ```

2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify environment and connected devices**:
   ```bash
   flutter doctor
   flutter devices
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

### Running the Test Suite

Execute the automated unit and widget test suite:

```bash
flutter test
```

### Static Analysis

Verify code quality and lint rules:

```bash
flutter analyze
```

---

## 7. API Information & Mock API Details

The application integrates with a cloud-hosted REST API backed by an offline-first caching layer.

### Mock API Configuration

- **Base URL**: `https://67bf170be922a942a0b16f1b.mockapi.io/api/v1`
- **Primary Endpoint**: `/visitors`
- **Availability**: The mock API is hosted on MockAPI.io and remains **publicly accessible 24/7** during evaluation.

### Endpoints Supported

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/visitors` | Retrieve full list of visitor records |
| `GET` | `/visitors/:id` | Fetch a single visitor by ID (e.g. `VST001`) |
| `POST` | `/visitors` | Register a new visitor record |
| `PUT` | `/visitors/:id` | Update visitor contact or visit details |
| `PATCH` | `/visitors/:id` | Update status (`Checked In` / `Checked Out`) and timestamps |
| `DELETE` | `/visitors/:id` | Remove a visitor record from the system |

### Sample JSON Record

```json
{
  "id": "VST001",
  "name": "Rahul Sharma",
  "mobile": "9876543210",
  "email": "rahul.sharma@example.com",
  "visitor_type": "Customer",
  "project": "Project A",
  "purpose": "Site Inspection",
  "status": "Registered",
  "created_at": "2026-10-27T10:00:00.000Z",
  "check_in_time": null,
  "check_out_time": null
}
```

### Offline & Fallback Handling

- **Automatic Caching**: When visitors are fetched, created, or updated via the remote API, the repository automatically mirrors the records in local persistent storage (`SharedPreferences`).
- **Offline Mode**: If the device loses internet connectivity or the remote endpoint responds with an error, the app transparently serves cached data.
- **Runtime Base URL**: The API base URL can be modified dynamically at runtime without restarting the application.

---

## 8. Screenshots

Visual overview of the key screens and workflows in the Visitor Management application:

### Dashboard & Analytics

| Dashboard Overview | Visitor Statistics |
| :---: | :---: |
| <img src="screenshots/01_dashboard.png" width="350" alt="Dashboard Screen" /> | <img src="screenshots/06_visitor_statistics.png" width="350" alt="Visitor Statistics Screen" /> |
| **Dashboard Screen**<br>Live counters (Total Today, Checked In, Checked Out), date selector, and quick action shortcuts | **Visitor Statistics Screen**<br>Weekly Monday–Sunday check-in/out bar chart and visitor type donut breakdown |

### Visitor Management & Passes

| Visitor List | Visitor Registration | Visitor Details & QR Pass |
| :---: | :---: | :---: |
| <img src="screenshots/02_visitor_list.png" width="240" alt="Visitor List Screen" /> | <img src="screenshots/03_visitor_registration.png" width="240" alt="Visitor Registration Screen" /> | <img src="screenshots/04_visitor_details_qr.png" width="240" alt="Visitor Details & QR Code Screen" /> |
| **Visitor List**<br>Searchable directory by name/mobile, project & type tags, status badges, and edit/delete actions | **Visitor Registration**<br>Validated form inputs (10-digit mobile, email format, dropdowns) | **Visitor Details & QR Code**<br>Full visitor profile, scannable QR badge, and instant check-in/out |

### QR Code Scanning & Verification Workflow

| Active Camera Scanner | Invalid QR Code Alert | Scanned Visitor Information |
| :---: | :---: | :---: |
| <img src="screenshots/05_qr_scanner.png" width="240" alt="Camera QR Scanner" /> | <img src="screenshots/05_qr_invalid_dialog.png" width="240" alt="Invalid QR Alert Dialog" /> | <img src="screenshots/05_scanned_visitor_info.png" width="240" alt="Scanned Visitor Information" /> |
| **Real-Time Camera Scanner**<br>Camera viewfinder with alignment frame, flash toggle, and manual ID fallback | **Invalid QR Validation**<br>Security check rejecting unrecognized passes with a clear alert message | **Extracted Visitor Information**<br>Extracted Visitor ID, live status, full profile, and Check In / Check Out actions |

| Screen | Description | File Path |
| :--- | :--- | :--- |
| **Dashboard** | Overview counters (Total Today, Checked In, Checked Out), date picker, and quick actions | [`screenshots/01_dashboard.png`](screenshots/01_dashboard.png) |
| **Visitor List** | Searchable and filterable visitor directory with status chips and quick actions | [`screenshots/02_visitor_list.png`](screenshots/02_visitor_list.png) |
| **Visitor Registration** | Form with field validation for mobile number, email, visitor type, and project | [`screenshots/03_visitor_registration.png`](screenshots/03_visitor_registration.png) |
| **Visitor Details & QR Code** | Full visitor profile, downloadable QR pass, and check-in/out timestamps | [`screenshots/04_visitor_details_qr.png`](screenshots/04_visitor_details_qr.png) |
| **QR Scanner (Live)** | Real-time camera viewfinder scanning visitor badge passes | [`screenshots/05_qr_scanner.png`](screenshots/05_qr_scanner.png) |
| **QR Scanner (Validation Alert)** | Validation dialog alerting guard when an unregistered QR code is scanned | [`screenshots/05_qr_invalid_dialog.png`](screenshots/05_qr_invalid_dialog.png) |
| **Scanned Visitor Information** | Extracted visitor ID banner, status badge, full details, and one-tap check in/out | [`screenshots/05_scanned_visitor_info.png`](screenshots/05_scanned_visitor_info.png) |
| **Visitor Statistics** | Weekly activity bar chart (Checked In vs. Checked Out) and visitor category donut chart | [`screenshots/06_visitor_statistics.png`](screenshots/06_visitor_statistics.png) |

---

## 9. Known Limitations

1. **Camera Scanning on Emulators**: The QR camera scanner requires an active camera input. When running on an emulator without a webcam mapped to the virtual camera, use the **"Enter ID Manually"** button to simulate scanning any visitor ID (e.g. `VST001`).
2. **File Storage Permissions on Android 9 and Lower**: The QR code download feature uses standard Android Scoped Storage (`/storage/emulated/0/Download/`). On Android 10+ it works seamlessly out of the box without requiring runtime storage permissions. On Android 9 or older, write storage permissions must be granted if saving to root storage.
3. **Mock API Rate Limiting**: The public mock API on MockAPI.io accommodates standard evaluation traffic; however, rapid automated stress testing (>100 requests/min) may trigger temporary rate limiting from MockAPI.io, during which the app safely falls back to local cache.
