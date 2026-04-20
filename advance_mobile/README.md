# Bike Sharing App (Advanced Mobile Final Project)

Flutter bike-sharing application built with MVVM architecture, Provider state
management, and GetIt dependency injection.

## Team Roles

- Reyu: Architecture, state management, models/DTOs, repository contracts, mock repositories, ViewModels.
- Elite: Firebase backend, real repositories, caching/offline, integration testing.
- Somnang: UI/UX system, reusable widgets, screens and interaction flow.

## Architecture Overview (MVVM Pattern)

The app follows a clean MVVM architecture with clear separation of concerns:

- **Model Layer** (`lib/model/`): Domain entities (Bike, Booking, Pass, Station, User)
- **Data Layer** (`lib/data/`): DTOs and repository implementations
- **UI Layer** (`lib/ui/`): Screens, ViewModels, theme, and widgets

### MVVM Flow

```
View (Screen) → ViewModel → Repository → Data Source/DTO → Domain Model
```

### Folder Structure

```
lib/
├── config/                     # App configuration
├── data/                       # Data layer
│   ├── dtos/                   # Data Transfer Objects
│   └── repositories/           # Repository implementations
│       ├── bike/
│       ├── booking/
│       ├── pass/
│       ├── station/
│       └── user/
├── model/                      # Domain models
│   ├── bike/
│   ├── booking/
│   ├── pass/
│   ├── station/
│   └── user/
├── ui/                         # Presentation layer
│   ├── screens/                # Feature screens
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── view_model/
│   │   ├── map/
│   │   │   ├── map_screen.dart
│   │   │   └── view_model/
│   │   ├── plans/
│   │   │   ├── plans_screen.dart
│   │   │   └── view_model/
│   │   ├── profile/
│   │   └── splash/
│   ├── theme/                  # Design system
│   └── widgets/                # Shared widgets
├── main.dart
└── service_locator.dart        # Dependency injection
```

## Current Project Status (Reyu scope)

Implemented:

- MVVM architecture with clean separation of layers
- Dependency injection setup in `lib/service_locator.dart`
- Domain Models in `lib/model/`: `User`, `Pass`, `Station`, `Bike`, `Booking`
- DTOs in `lib/data/dtos/`
- Repository interfaces and mock implementations in `lib/data/repositories/`
- ViewModels (co-located with screens):
  - `PassViewModel` (US1) - in `ui/screens/plans/view_model/`
  - `MapViewModel` (US2) - in `ui/screens/map/view_model/`
  - `BikeViewModel` (US3) - in `ui/screens/map/view_model/`
  - `BookingViewModel` (US4) - in `ui/screens/home/view_model/`
- Screens in `lib/ui/screens/`:
  - `HomeScreen`, `MapScreen`, `PlansScreen`, `ProfileScreen`
- Unit tests for all ViewModels in `test/unit/`

## US4 Critical Logic (Implemented)

`BookingViewModel.bookBike()` enforces:

- If user has active pass → booking proceeds
- If user has no active pass → booking is blocked and flow status is set to
  `requiresPassSelection`

This behavior is validated by unit tests in
`test/unit/booking_viewmodel_test.dart`.

## Run Locally

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Key Files

- `lib/main.dart` - App entry point
- `lib/service_locator.dart` - Dependency injection setup
- `lib/ui/screens/*/view_model/*.dart` - ViewModels
- `lib/data/repositories/` - Repository contracts and implementations
- `lib/model/` - Domain models
- `test/unit/` - Unit tests

## Next Integration Steps (Elite + Somnang)

### Elite (Firebase Integration)
- Add Firebase repository implementations:
  - `lib/data/repositories/pass/pass_repository_firebase.dart`
  - `lib/data/repositories/bike/bike_repository_firebase.dart`
  - `lib/data/repositories/station/station_repository_firebase.dart`
  - `lib/data/repositories/booking/booking_repository_firebase.dart`
  - `lib/data/repositories/user/user_repository_firebase.dart`
- Connect real-time streams and atomic booking transactions
- Update `service_locator.dart` to switch between mock and Firebase implementations

### Somnang (UI/UX)
- Create feature-specific widgets in `lib/ui/screens/*/widgets/`
- Add shared widgets in `lib/ui/widgets/`
- Enhance screens with final design system components
- Implement navigation flows between screens
