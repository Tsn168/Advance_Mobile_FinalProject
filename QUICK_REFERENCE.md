# 🎯 Quick Reference Guide

## File Architecture at a Glance

```
📱 Bike Sharing App
│
├── 🎨 Theme (Somnang - Frontend)
│   └── lib/theme/
│       ├── app_colors.dart ✅
│       ├── app_text_styles.dart ✅
│       ├── app_spacing.dart ✅
│       ├── app_dimensions.dart ✅
│       └── app_theme.dart ✅
│
├── 🏗️ Data Models (Reyu - Business Logic)
│   ├── lib/models/
│   │   ├── user.dart ✅
│   │   ├── pass.dart ✅
│   │   ├── station.dart ✅
│   │   ├── bike.dart ✅
│   │   └── booking.dart ✅
│   │
│   └── lib/dtos/
│       ├── pass_dto.dart ✅
│       ├── station_dto.dart ✅
│       ├── bike_dto.dart ✅
│       └── booking_dto.dart ✅
│
├── 📦 Repositories
│   ├── Base (Reyu)
│   │   └── lib/repositories/base/
│   │       ├── pass_repository.dart ✅
│   │       ├── station_repository.dart ✅
│   │       ├── bike_repository.dart ✅
│   │       └── booking_repository.dart ✅
│   │
│   ├── Mock (Reyu) - TODO
│   │   └── lib/repositories/mock/
│   │       ├── mock_pass_repository.dart
│   │       ├── mock_station_repository.dart
│   │       ├── mock_bike_repository.dart
│   │       └── mock_booking_repository.dart
│   │
│   ├── Firebase (Elite) - TODO
│   │   └── lib/repositories/firebase/
│   │       ├── firebase_pass_repository.dart
│   │       ├── firebase_station_repository.dart
│   │       ├── firebase_bike_repository.dart
│   │       └── firebase_booking_repository.dart
│   │
│   └── Local Storage (Elite) - TODO
│       └── lib/repositories/local/
│           ├── local_storage_service.dart
│           ├── shared_preferences_helper.dart
│           └── cache_manager.dart
│
├── 🎬 ViewModels (Reyu) - TODO
│   └── lib/viewmodels/
│       ├── pass_viewmodel.dart
│       ├── map_viewmodel.dart
│       ├── bike_viewmodel.dart
│       └── booking_viewmodel.dart
│
├── 🎨 UI Screens & Widgets (Somnang) - TODO
│   ├── lib/widgets/
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_card.dart
│   │   │   ├── custom_textfield.dart
│   │   │   ├── custom_dialog.dart
│   │   │   └── loading_indicator.dart
│   │   ├── pass/
│   │   │   ├── pass_card.dart
│   │   │   └── pass_type_selector.dart
│   │   ├── map/
│   │   │   ├── station_marker.dart
│   │   │   └── station_info_card.dart
│   │   └── bikes/
│   │       ├── bike_card.dart
│   │       └── bike_slot_indicator.dart
│   │
│   └── lib/views/
│       ├── pass/
│       │   └── pass_selection_screen.dart
│       ├── map/
│       │   └── map_screen.dart
│       ├── bikes/
│       │   └── bikes_list_screen.dart
│       ├── booking/
│       │   ├── booking_confirmation_screen.dart
│       │   └── current_booking_panel.dart
│       └── payment/
│           └── payment_screen.dart
│
├── 🔧 Services & Config (Elite) - TODO
│   ├── lib/services/
│   │   ├── firebase_service.dart
│   │   ├── local_storage_service.dart
│   │   ├── error_handler.dart
│   │   └── push_notification_service.dart
│   │
│   └── lib/config/
│       ├── firebase_config.dart
│       └── app_constants.dart ✅
│
├── 🔌 Dependency Injection (Reyu)
│   └── lib/service_locator.dart ✅
│
├── 📱 App Entry Point (All)
│   └── lib/main.dart ✅ (needs update)
│
└── 🧪 Tests (Elite) - TODO
    └── test/
        ├── unit/
        │   ├── pass_viewmodel_test.dart
        │   ├── map_viewmodel_test.dart
        │   ├── bike_viewmodel_test.dart
        │   └── booking_viewmodel_test.dart
        └── integration/
            ├── firebase_integration_test.dart
            └── booking_flow_test.dart
```

## Color Palette Quick Reference

| Color | Hex | Use Case |
|-------|-----|----------|
| Primary | #6C63FF | Main buttons, highlights |
| Secondary | #FF6B6B | Alternative action |
| Success | #00C851 | Available bikes, success messages |
| Error | #FF4444 | Errors, unavailable bikes |
| Warning | #FFC107 | Maintenance, warnings |
| Info | #2196F3 | Information, status |
| Background | #FAFAFA | App background |
| Surface | #FFFFFF | Cards, containers |
| Text Primary | #212121 | Main text |
| Text Secondary | #757575 | Secondary text |

## Spacing System Quick Reference

| Spacing | Size | Use Case |
|---------|------|----------|
| xxs | 2px | Extra small gaps |
| xs | 4px | Small gaps |
| sm | 8px | Small padding |
| md | 16px | Standard padding |
| lg | 24px | Large padding |
| xl | 32px | Extra large spacing |
| xxl | 48px | Extra extra large |

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────┐
│ User Interaction (Tap Button)                       │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│ View (Screen)                                       │
│ - PassSelectionScreen                              │
│ - MapScreen                                         │
│ - BookingScreen                                     │
│ Uses: Consumer<ViewModel>                           │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│ ViewModel                                           │
│ - PassViewModel                                     │
│ - MapViewModel                                      │
│ - BookingViewModel                                  │
│ Manages: Loading, Error, Data states               │
│ Calls: Repository methods                          │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────┐
│ Repository (Abstract Interface)                     │
│ - IPassRepository                                   │
│ - IStationRepository                                │
│ - IBikeRepository                                   │
│ - IBookingRepository                                │
└─┬──────────────────────────────┬────────────────────┘
  │                              │
  ▼                              ▼
┌──────────────────┐    ┌─────────────────────────────┐
│ Mock Repository  │    │ Real Repository             │
│ (Development)    │    │ (Firebase)                  │
│ Returns Test     │    │ Connects to                 │
│ Data             │    │ - Cloud Firestore          │
│                  │    │ - Realtime Database         │
│                  │    │ - Authentication           │
└──────────────────┘    └─────────────────────────────┘
```

## User Story to Code Mapping

| User Story | Screen | ViewModel | Repository | Models |
|------------|--------|-----------|------------|--------|
| US1: Select Pass | PassSelectionScreen | PassViewModel | IPassRepository | Pass |
| US2: View Stations | MapScreen | MapViewModel | IStationRepository | Station |
| US3: View Bikes | BikeListScreen | BikeViewModel | IBikeRepository | Bike |
| US4: Book Bike | BookingScreen | BookingViewModel | IBookingRepository | Booking |
| US5: Payment | PaymentScreen | PaymentViewModel | IBookingRepository | Pass/Booking |
| US6: Pick up Bike | CurrentBookingPanel | BookingViewModel | IBookingRepository | Booking |

## Team Contribution Summary

### Somnang
- Creates all UI files (widgets + screens)
- Manages `lib/theme/` folder
- Manages `lib/widgets/` folder
- Manages `lib/views/` folder
- ~40% of code

### Reyu
- Creates ViewModels and state management
- Creates data models and DTOs
- Creates repository interfaces
- Creates mock repositories
- Manages `lib/viewmodels/` folder
- Manages `lib/models/` folder
- Manages `lib/dtos/` folder
- ~35% of code

### Elite
- Creates real Firebase repositories
- Creates local storage services
- Creates tests
- Manages `lib/repositories/firebase/` folder
- Manages `lib/repositories/local/` folder
- Manages `lib/services/` folder
- Manages `test/` folder
- ~25% of code

## Implementation Order

### Phase 1: Foundation (Week 1)
1. Somnang creates theme system ✅
2. Reyu creates models & DTOs ✅
3. Reyu creates repository interfaces ✅
4. Elite designs Firebase collections

### Phase 2: Development (Week 2)
1. Somnang builds all screens & widgets
2. Reyu creates ViewModels with mock data
3. Elite implements Firebase repositories
4. Elite sets up local storage

### Phase 3: Integration (Week 3)
1. Connect UI to ViewModels
2. Switch from mock to real repositories
3. Add error handling
4. Run all tests
5. Final polish

## Testing Strategy

```
┌─────────────────────────────────────┐
│ Unit Tests                          │
│ - Model serialization               │
│ - ViewModel logic                   │
│ - Repository methods                │
└─────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────┐
│ Integration Tests                   │
│ - Full user flows                   │
│ - Firebase connections              │
│ - Error scenarios                   │
└─────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────┐
│ Manual Testing                      │
│ - UI/UX quality                     │
│ - Performance                       │
│ - Edge cases                        │
└─────────────────────────────────────┘
```

## Key Principles to Remember

### ✅ DO
- Use theme constants for all colors/sizes
- Implement loading/error states in ViewModels
- Test your code before merging
- Comment complex logic
- Break screens into reusable widgets
- Use immutable models
- Handle exceptions gracefully

### ❌ DON'T
- Hard-code colors or sizes
- Put business logic in UI
- Skip error handling
- Create huge Widget files
- Forget to notify listeners after state change
- Ignore test failures
- Commit without testing

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/us1-select-pass

# Make changes
# Add files
git add .

# Commit
git commit -m "feat(US1): Add pass selection screen"

# Push
git push origin feature/us1-select-pass

# Create Pull Request in GitHub
# Link to JIRA ticket
```

## Debugging Tips

### If app crashes on startup
1. Check service_locator.dart - is getIt initialized?
2. Check pubspec.yaml - are all packages installed?
3. Run `flutter clean` and `flutter pub get`

### If UI doesn't update
1. Check if notifyListeners() is called in ViewModel
2. Check if using Consumer<ViewModel> correctly
3. Check if ViewModel is registered in service_locator

### If Firebase data doesn't load
1. Check Firebase credentials
2. Check collection names match exactly
3. Check Firestore rules allow read access
4. Check network connectivity

## Quick Commands

```bash
# Run app
flutter run

# Build APK
flutter build apk

# Run tests
flutter test

# Format code
dart format lib/

# Analyze code
flutter analyze

# Clean build
flutter clean
flutter pub get
```

## Resources

- Flutter Docs: https://flutter.dev
- Provider Package: https://pub.dev/packages/provider
- Firebase Flutter: https://firebase.flutter.dev
- Material Design: https://material.io

---

**Last Updated:** April 17, 2026
**Project:** Bike Sharing App Final Project
