# 🚲 Bike Sharing App - Project Architecture

## Project Overview

This is a Flutter-based bike sharing mobile application developed for **Advanced Mobile Development (Term 2)**. The project implements 6 user stories using a modern, clean architecture with MVVM, Dependency Injection, Provider state management, and Firebase integration.

**Team Members:**
- **Somnang** - UI/UX & Frontend Design Lead
- **Reyu** - State Management & Business Logic Lead
- **Elite** - Backend & Firebase Integration Lead

---

## 📁 Project Structure

```
lib/
├── theme/                          # Design System & Theme (Somnang)
│   ├── app_colors.dart            # Color constants
│   ├── app_text_styles.dart       # Typography styles
│   ├── app_spacing.dart           # Spacing constants
│   ├── app_dimensions.dart        # Dimension constants
│   └── app_theme.dart             # Complete theme definition
│
├── models/                        # Data Models (Reyu)
│   ├── user.dart
│   ├── pass.dart
│   ├── station.dart
│   ├── bike.dart
│   └── booking.dart
│
├── dtos/                          # Data Transfer Objects (Reyu)
│   ├── pass_dto.dart
│   ├── station_dto.dart
│   ├── bike_dto.dart
│   └── booking_dto.dart
│
├── repositories/
│   ├── base/                      # Abstract Interfaces (Reyu)
│   │   ├── pass_repository.dart
│   │   ├── station_repository.dart
│   │   ├── bike_repository.dart
│   │   └── booking_repository.dart
│   ├── mock/                      # Mock Implementations (Reyu)
│   │   ├── mock_pass_repository.dart
│   │   ├── mock_station_repository.dart
│   │   ├── mock_bike_repository.dart
│   │   └── mock_booking_repository.dart
│   ├── firebase/                  # Firebase Implementations (Elite)
│   │   ├── firebase_pass_repository.dart
│   │   ├── firebase_station_repository.dart
│   │   ├── firebase_bike_repository.dart
│   │   └── firebase_booking_repository.dart
│   └── local/                     # Local Storage (Elite)
│       ├── local_storage_service.dart
│       ├── shared_preferences_helper.dart
│       └── cache_manager.dart
│
├── viewmodels/                    # ViewModels (Reyu)
│   ├── pass_viewmodel.dart
│   ├── map_viewmodel.dart
│   ├── bike_viewmodel.dart
│   └── booking_viewmodel.dart
│
├── views/                         # UI Screens (Somnang)
│   ├── pass/
│   │   └── pass_selection_screen.dart
│   ├── map/
│   │   └── map_screen.dart
│   ├── bikes/
│   │   └── bikes_list_screen.dart
│   ├── booking/
│   │   ├── booking_confirmation_screen.dart
│   │   └── current_booking_panel.dart
│   └── payment/
│       └── payment_screen.dart
│
├── widgets/                       # Reusable Widgets (Somnang)
│   ├── common/
│   │   ├── custom_button.dart
│   │   ├── custom_card.dart
│   │   ├── custom_textfield.dart
│   │   ├── custom_dialog.dart
│   │   └── loading_indicator.dart
│   ├── pass/
│   │   ├── pass_card.dart
│   │   ├── pass_type_selector.dart
│   │   └── expiry_date_display.dart
│   ├── map/
│   │   ├── station_marker.dart
│   │   ├── station_info_card.dart
│   │   └── available_bikes_badge.dart
│   └── bikes/
│       ├── bike_card.dart
│       ├── bike_slot_indicator.dart
│       └── slot_status_widget.dart
│
├── services/                      # Business Services (Elite)
│   ├── firebase_service.dart
│   ├── local_storage_service.dart
│   ├── error_handler.dart
│   └── push_notification_service.dart
│
├── config/                        # Configuration & Constants (Elite)
│   ├── firebase_config.dart
│   └── app_constants.dart
│
├── service_locator.dart           # Dependency Injection Setup (Reyu)
├── main.dart                      # App Entry Point (All)
│
test/                             # Tests (Elite)
├── unit/
│   ├── pass_viewmodel_test.dart
│   ├── map_viewmodel_test.dart
│   ├── bike_viewmodel_test.dart
│   └── booking_viewmodel_test.dart
└── integration/
    ├── firebase_integration_test.dart
    └── booking_flow_test.dart
```

---

## 🏗️ Architecture Overview

### MVVM Architecture

```
View (UI)
  ↓
ViewModel (Business Logic)
  ↓
Repository (Data Access)
  ↓
Data Source (Firebase / Local Storage / Mock)
```

### Separation of Concerns

1. **UI Layer (Views & Widgets)** - Somnang
   - Presentation logic only
   - Uses Consumer<ViewModel> for state updates
   - No business logic in UI

2. **Business Logic Layer (ViewModels)** - Reyu
   - Manages screen state
   - Handles async operations
   - Error handling
   - Loading states

3. **Data Layer (Repositories)** - Elite
   - Abstract interfaces for flexibility
   - Mock implementations for testing
   - Real Firebase implementations for production
   - Local storage for caching

---

## 👥 Team Responsibilities

### Somnang - UI/UX & Frontend

**Deliverables:**
- ✅ App Theme with design system (colors, typography, spacing)
- ✅ Reusable widget library
- ✅ All screen layouts
- ✅ Nielsen's 10 Usability Heuristics validation

**Files:**
- `theme/*` - All theme files
- `widgets/*` - All reusable components
- `views/*` - All screen UI

**User Stories:**
- US1: Select a Pass (UI)
- US2: View Stations on Map (UI)

### Reyu - State Management & Business Logic

**Deliverables:**
- ✅ MVVM architecture setup
- ✅ Dependency Injection with get_it
- ✅ Provider state management
- ✅ All ViewModels
- ✅ Models and DTOs
- ✅ Mock repositories

**Files:**
- `service_locator.dart` - DI setup
- `models/*` - Data models
- `dtos/*` - Data transfer objects
- `repositories/base/*` - Abstract interfaces
- `repositories/mock/*` - Mock implementations
- `viewmodels/*` - ViewModels

**User Stories:**
- US3: View Bikes at Station (ViewModel & Logic)
- US4: Book a Bike (ViewModel & Logic)

### Elite - Backend & Firebase Integration

**Deliverables:**
- ✅ Firebase configuration & integration
- ✅ Real repositories
- ✅ Local storage setup
- ✅ Error handling
- ✅ Unit & integration tests
- ✅ Push notifications (optional)

**Files:**
- `repositories/firebase/*` - Firebase implementations
- `repositories/local/*` - Local storage
- `services/*` - Business services
- `config/*` - Configuration
- `test/*` - All tests

**User Stories:**
- US5: Payment (Backend)
- US6: Pick up the Bike (Persistence)

---

## 🔄 Data Flow Example: Booking a Bike

```
1. User Clicks "Book Bike"
   ↓
2. BookingScreen (View)
   - Calls bookingViewModel.bookBike()
   ↓
3. BookingViewModel
   - Check if user has active pass
   - If no pass: redirect to pass selection
   - If has pass: call bookingRepository.createBooking()
   ↓
4. Repository (Mock or Firebase)
   - Create booking in database
   - Update bike status to BOOKED
   - Update station's available bikes count
   ↓
5. Return Booking object
   ↓
6. ViewModel updates state
   - Loading state → Success
   - Notify UI with Consumer<BookingViewModel>
   ↓
7. UI Updates
   - Show booking confirmation
   - Navigate to current booking panel
```

---

## 📦 Installation & Setup

### 1. Add Dependencies

Edit `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  get_it: ^7.6.0
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  firebase_auth: ^4.10.0
  shared_preferences: ^2.2.0
  google_maps_flutter: ^2.5.0  # For map feature
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
```

### 2. Initialize Service Locator

In `main.dart`:

```dart
import 'service_locator.dart';
import 'theme/app_theme.dart';

void main() {
  setupServiceLocator();  // Initialize DI
  runApp(const BikeShareApp());
}
```

### 3. Set Up Provider

In `main.dart`:

```dart
import 'package:provider/provider.dart';
import 'viewmodels/pass_viewmodel.dart';
import 'viewmodels/map_viewmodel.dart';
import 'viewmodels/bike_viewmodel.dart';
import 'viewmodels/booking_viewmodel.dart';

class BikeShareApp extends StatelessWidget {
  const BikeShareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<PassViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<MapViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<BikeViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<BookingViewModel>()),
      ],
      child: MaterialApp(
        title: 'Bike Share',
        theme: AppTheme.lightTheme,
        home: const MapScreen(),
      ),
    );
  }
}
```

---

## 📱 User Stories Implementation

### US1 - Select a Pass
- **Status**: In Progress
- **Frontend**: Pass selection screen with pass type cards
- **Backend**: Pass creation and user pass association
- **Storage**: Firebase passes collection

### US2 - View Stations on Map
- **Status**: In Progress
- **Frontend**: Google Maps with station markers
- **Backend**: Real-time station data with Streams
- **Storage**: Firebase stations collection

### US3 - View Bikes at Station
- **Status**: In Progress
- **Frontend**: List of bikes with slot status
- **Backend**: Filtering available bikes
- **Storage**: Firebase bikes collection

### US4 - Book a Bike
- **Status**: In Progress
- **Frontend**: Booking confirmation dialog
- **Backend**: Pass validation, bike booking
- **Storage**: Firebase bookings collection

### US5 - Payment (Optional)
- **Status**: Planned
- **Frontend**: Payment screen
- **Backend**: Payment gateway integration
- **Storage**: Payment records

### US6 - Pick up the Bike (Optional)
- **Status**: Planned
- **Frontend**: Current booking panel
- **Backend**: Booking persistence
- **Storage**: Local storage & Firebase

---

## 🎨 Design System

### Colors
- Primary: `#6C63FF` (Purple)
- Secondary: `#FF6B6B` (Red)
- Success: `#00C851` (Green)
- Error: `#FF4444` (Red)
- Background: `#FAFAFA` (Light Gray)

### Typography
- Heading 1: 32px, Bold
- Body: 14px, Regular
- Button: 16px, Semi-bold
- Caption: 11px, Regular

### Spacing (Base Unit: 4px)
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px

---

## 🧪 Testing Strategy

### Unit Tests (Elite)
- ViewModel logic tests
- Repository tests
- Model serialization tests

### Integration Tests (Elite)
- Firebase connection tests
- Full user flow tests
- Error handling tests

**Run Tests:**
```bash
flutter test
```

---

## 🚀 Development Workflow

### Week 1: Foundation
- Somnang: Extract Figma design, create theme
- Reyu: Set up MVVM, create models/DTOs
- Elite: Set up Firebase, design collections

### Week 2: Implementation
- Somnang: Build all screens and widgets
- Reyu: Create ViewModels, integrate with UI
- Elite: Implement real repositories, local storage

### Week 3: Integration & Polish
- All: Connect all layers
- Elite: Write tests
- All: Bug fixes, final polish

---

## 📋 Checklist for Teacher Evaluation

- [ ] PART 1 - UX/UI
  - [ ] Wireframes validate Nielsen's 10 Heuristics
  - [ ] Design System defined in Figma

- [ ] PART 2 - WIDGETS ARCHITECTURE
  - [ ] App Theme well defined with Design System
  - [ ] No hard-coded styles
  - [ ] Reusable widget library created
  - [ ] Screens organized with sub-widgets

- [ ] PART 2 - STATE ARCHITECTURE
  - [ ] State architecture well defined (global/screen/widget)
  - [ ] MVVM architecture: VM manages logic, VIEW is presentation-focused

- [ ] PART 3 - DATA ARCHITECTURE
  - [ ] Repositories defined through abstract interfaces
  - [ ] DTOs used for data transfer
  - [ ] Mock AND real repositories implemented
  - [ ] Async calls handled correctly (Future, Streams)
  - [ ] Loading and error states in VM and View

- [ ] PART 4 - FIREBASE & LOCAL STORAGE
  - [ ] App connected to Firebase
  - [ ] Collections properly designed
  - [ ] Data models mapped to Firebase documents
  - [ ] Push notifications integrated (Optional)

- [ ] PART 6 - TEAMWORK
  - [ ] Jira User Stories well-defined
  - [ ] Subtasks assigned per team member
  - [ ] Clear division of responsibilities

- [ ] PART 7 - FEATURES
  - [ ] At least 50% of user specifications implemented
  - [ ] All 6 user stories working

---

## 📚 Resources & Documentation

- [Flutter Official Docs](https://flutter.dev)
- [Provider Pattern](https://pub.dev/packages/provider)
- [GetIt (DI)](https://pub.dev/packages/get_it)
- [Firebase for Flutter](https://firebase.flutter.dev)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)

---

## 🔗 Important Files to Remember

**For Somnang (UI/UX):**
- `lib/theme/app_colors.dart`
- `lib/theme/app_text_styles.dart`
- `lib/theme/app_theme.dart`
- `lib/widgets/*`
- `lib/views/*`

**For Reyu (State Management):**
- `lib/service_locator.dart`
- `lib/models/*`
- `lib/dtos/*`
- `lib/repositories/base/*`
- `lib/repositories/mock/*`
- `lib/viewmodels/*`

**For Elite (Backend):**
- `lib/repositories/firebase/*`
- `lib/repositories/local/*`
- `lib/services/*`
- `lib/config/*`
- `test/*`

---

## 💡 Tips for Success

1. **Always use the theme** - Don't hard-code colors or sizes
2. **Follow MVVM** - Keep UI and logic separate
3. **Use abstract interfaces** - Makes testing and switching implementations easy
4. **Handle errors gracefully** - Show meaningful messages to users
5. **Test thoroughly** - Write tests as you code
6. **Communicate** - Share your progress with teammates daily
7. **Document your code** - Use comments to explain complex logic

---

## 📞 Support

For questions or issues:
- Create JIRA tickets for bugs/features
- Communicate in Telegram group
- Review code before merging

---

**Last Updated:** April 17, 2026  
**Team:** Somnang, Reyu, Elite  
**Project:** Bike Sharing App - Mobile Development Final Project
