# Visitor Management App

A Flutter mobile application designed for security and front desk teams to manage visitor check-ins, register new visitors, generate downloadable QR passes, scan visitor badges, and monitor visitor statistics across residential and commercial premises.

## Features

- **Front Desk Authentication**: Login screen with form validation (uppercase, number, and special character requirements).
- **Visitor Registration**: Collects visitor name, 10-digit mobile number, optional email, visitor category (Customer, Vendor, Other), assigned project, and purpose of visit.
- **QR Pass Generation & Download**: Generates high-resolution QR codes containing the visitor ID, with one-tap download directly to the device's Downloads folder using MediaStore Scoped Storage.
- **Camera QR Code Scanner**: Built using `mobile_scanner`. Automatically extracts the visitor ID, queries the API/local database for the visitor's record, displays visitor details and status, and provides clear error feedback when scanning an invalid code.
- **Check-In & Check-Out Management**: Allows staff to check in registered visitors and scan to check out with visual confirmation cards and time logging.
- **Visitor Statistics & Trends**: Interactive date picker to view weekly activity (Checked In vs Checked Out bar charts) and visitor category distribution (Donut chart).
- **Offline-First Storage**: Caches visitor records locally in `SharedPreferences` so the app remains responsive even during network interruptions.
- **Empty State UX**: Displays clean empty state illustrations when no visitors are registered yet.

## Architecture

The project is structured around the **BLoC (Business Logic Component)** pattern to maintain a clean separation between UI and state management:

```
lib/
├── core/
│   ├── constants/       # App colors, API endpoints, and centralized strings
│   ├── theme/           # ThemeData, input decorations, and typography
│   ├── utils/           # Date formatting and input validation helpers
│   └── widgets/         # Shared UI components (buttons, cards, chips, shimmers)
├── data/
│   ├── datasources/     # Local storage (SharedPreferences) and REST API client
│   ├── models/          # Visitor data models and JSON serialization
│   └── repositories/    # Repository coordinating local cache and remote API
├── logic/
│   └── blocs/
│       ├── auth/        # Authentication BLoC (Login, Logout, Session check)
│       └── visitor/     # Visitor CRUD, search, filter, scanning, and status BLoC
└── presentation/
    └── screens/
        ├── auth/        # Login screen
        ├── dashboard/   # Main dashboard with key metrics and quick actions
        ├── main/        # Bottom navigation controller
        ├── scanner/     # QR scanner and scanned visitor info screens
        ├── splash/      # Splash screen
        ├── statistics/  # Weekly trends and visitor type charts
        ├── success/     # Check-in and check-out confirmation screens
        └── visitors/    # Visitor list, registration, details, and QR screens
```

## Getting Started

### Prerequisites

- Flutter SDK (v3.19.0 or higher)
- Dart SDK (v3.3.0 or higher)
- Android Studio / VS Code with Flutter extension
- An Android device or emulator with camera support (for QR scanning)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd visitor_mangement_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

### Running Tests

To run the unit and widget tests:

```bash
flutter test
```

## Dependencies

- `flutter_bloc`: State management
- `mobile_scanner`: Camera-based QR and barcode scanning
- `qr_flutter`: QR code image generation
- `shared_preferences`: Local device persistence
- `http`: REST API communication
- `intl`: Date and timestamp formatting
