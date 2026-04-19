# 🚲 Bike Sharing App - Project Structure Summary

## Quick Start Guide

### ✅ What's Been Created

The complete file architecture for your Flutter project has been set up:

#### Theme System (Somnang)
- ✅ `lib/theme/app_colors.dart` - All color constants
- ✅ `lib/theme/app_text_styles.dart` - Typography styles
- ✅ `lib/theme/app_spacing.dart` - Spacing constants (4px base unit)
- ✅ `lib/theme/app_dimensions.dart` - Component dimensions
- ✅ `lib/theme/app_theme.dart` - Complete Material 3 theme

#### Models & DTOs (Reyu)
- ✅ `lib/models/user.dart` - User model
- ✅ `lib/models/pass.dart` - Pass model with types (Day, Weekly, Monthly, Annual)
- ✅ `lib/models/station.dart` - Station model
- ✅ `lib/models/bike.dart` - Bike model with status & condition
- ✅ `lib/models/booking.dart` - Booking model

- ✅ `lib/dtos/pass_dto.dart` - DTO with Firebase conversion
- ✅ `lib/dtos/station_dto.dart` - DTO with Firebase conversion
- ✅ `lib/dtos/bike_dto.dart` - DTO with Firebase conversion
- ✅ `lib/dtos/booking_dto.dart` - DTO with Firebase conversion

#### Repository Architecture (Reyu & Elite)
- ✅ `lib/repositories/base/pass_repository.dart` - Abstract interface
- ✅ `lib/repositories/base/station_repository.dart` - Abstract interface
- ✅ `lib/repositories/base/bike_repository.dart` - Abstract interface
- ✅ `lib/repositories/base/booking_repository.dart` - Abstract interface

#### Dependency Injection & Configuration
- ✅ `lib/service_locator.dart` - DI setup with get_it
- ✅ `lib/config/app_constants.dart` - Error handling & app states

#### Directory Structure
- ✅ `lib/widgets/common/` - For reusable widgets (Somnang)
- ✅ `lib/widgets/pass/` - Pass-specific widgets (Somnang)
- ✅ `lib/widgets/map/` - Map widgets (Somnang)
- ✅ `lib/widgets/bikes/` - Bike widgets (Somnang)
- ✅ `lib/views/pass/` - Pass selection screen (Somnang)
- ✅ `lib/views/map/` - Map screen (Somnang)
- ✅ `lib/views/bikes/` - Bikes list screen (Somnang)
- ✅ `lib/views/booking/` - Booking screens (Somnang)
- ✅ `lib/views/payment/` - Payment screen (Somnang)
- ✅ `lib/viewmodels/` - All ViewModels (Reyu)
- ✅ `lib/repositories/mock/` - Mock implementations (Reyu)
- ✅ `lib/repositories/firebase/` - Firebase implementations (Elite)
- ✅ `lib/repositories/local/` - Local storage (Elite)
- ✅ `lib/services/` - Business services (Elite)
- ✅ `test/` - Unit & integration tests (Elite)

---

## 📝 Next Steps for Each Team Member

### For Somnang (UI/UX & Frontend)

**Immediate Tasks:**
1. Create all reusable widgets in `lib/widgets/`
   - Custom buttons, cards, textfields, dialogs
   - Pass cards, pass type selector
   - Station markers, bike cards, slot indicators

2. Build screen skeletons in `lib/views/`
   - PassSelectionScreen
   - MapScreen
   - BikeListScreen
   - BookingConfirmationScreen
   - CurrentBookingPanel

3. Use AppTheme in all widgets (NO hard-coded styles!)
   ```dart
   // ✅ CORRECT - Use theme constants
   ElevatedButton(
     style: ElevatedButton.styleFrom(
       backgroundColor: AppColors.primary,
       padding: EdgeInsets.all(AppSpacing.md),
     ),
   )
   
   // ❌ WRONG - Hard-coded colors
   ElevatedButton(
     style: ElevatedButton.styleFrom(
       backgroundColor: Color(0xFF6C63FF),
       padding: EdgeInsets.all(16),
     ),
   )
   ```

**Files to Create:**
- `lib/widgets/common/custom_button.dart`
- `lib/widgets/common/custom_card.dart`
- `lib/widgets/common/custom_textfield.dart`
- `lib/widgets/pass/pass_card.dart`
- `lib/widgets/map/station_marker.dart`
- `lib/widgets/bikes/bike_card.dart`
- `lib/views/pass/pass_selection_screen.dart`
- `lib/views/map/map_screen.dart`
- etc.

---

### For Reyu (State Management & Business Logic)

**Immediate Tasks:**
1. Create all ViewModels in `lib/viewmodels/`
   - PassViewModel
   - MapViewModel
   - BikeViewModel
   - BookingViewModel

2. Implement Mock Repositories in `lib/repositories/mock/`
   - MockPassRepository
   - MockStationRepository
   - MockBikeRepository
   - MockBookingRepository

3. Test ViewModel logic with mock data

**Example ViewModel Structure:**
```dart
import 'package:flutter/foundation.dart';
import '../repositories/base/bike_repository.dart';
import '../models/bike.dart';
import '../config/app_constants.dart';

class BikeViewModel extends ChangeNotifier {
  final IBikeRepository _bikeRepository;
  
  AppState _state = AppState.idle;
  String? _errorMessage;
  List<Bike> _bikes = [];
  
  BikeViewModel(this._bikeRepository);
  
  // Getters
  AppState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Bike> get bikes => _bikes;
  
  // Get bikes at station
  Future<void> getBikesByStation(String stationId) async {
    _state = AppState.loading;
    notifyListeners();
    
    try {
      _bikes = await _bikeRepository.getBikesByStation(stationId);
      _state = AppState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
    }
    notifyListeners();
  }
}
```

**Files to Create:**
- `lib/viewmodels/pass_viewmodel.dart`
- `lib/viewmodels/map_viewmodel.dart`
- `lib/viewmodels/bike_viewmodel.dart`
- `lib/viewmodels/booking_viewmodel.dart`
- `lib/repositories/mock/mock_pass_repository.dart`
- `lib/repositories/mock/mock_station_repository.dart`
- `lib/repositories/mock/mock_bike_repository.dart`
- `lib/repositories/mock/mock_booking_repository.dart`

---

### For Elite (Backend & Firebase Integration)

**Immediate Tasks:**
1. Set up Firebase project
   - Create Firebase console project
   - Download google-services.json (Android)
   - Configure iOS

2. Design Firebase collections
   - `users/`
   - `passes/`
   - `stations/`
   - `bikes/`
   - `bookings/`

3. Implement real Firebase repositories

**Example Firebase Repository:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/bike_repository.dart';
import '../../models/bike.dart';
import '../../dtos/bike_dto.dart';

class FirebaseBikeRepository implements IBikeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<List<Bike>> getBikesByStation(String stationId) async {
    try {
      final snapshot = await _firestore
          .collection('bikes')
          .where('stationId', isEqualTo: stationId)
          .get();
      
      return snapshot.docs
          .map((doc) => BikeDTO.fromFirebase(doc.data()).toModel())
          .toList();
    } catch (e) {
      throw Exception('Failed to get bikes: $e');
    }
  }
  
  // ... other methods
}
```

**Files to Create:**
- `lib/repositories/firebase/firebase_pass_repository.dart`
- `lib/repositories/firebase/firebase_station_repository.dart`
- `lib/repositories/firebase/firebase_bike_repository.dart`
- `lib/repositories/firebase/firebase_booking_repository.dart`
- `lib/repositories/local/shared_preferences_helper.dart`
- `lib/services/firebase_service.dart`
- Test files in `test/`

---

## 🔗 How to Connect Everything

### 1. Update pubspec.yaml
Add required dependencies:
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  get_it: ^7.6.0
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  shared_preferences: ^2.2.0
  google_maps_flutter: ^2.5.0
```

### 2. Update service_locator.dart
```dart
import 'package:get_it/get_it.dart';
import 'repositories/base/pass_repository.dart';
import 'repositories/mock/mock_pass_repository.dart';
import 'viewmodels/pass_viewmodel.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Register Repositories
  getIt.registerSingleton<IPassRepository>(MockPassRepository());
  
  // Register ViewModels
  getIt.registerSingleton<PassViewModel>(
    PassViewModel(getIt<IPassRepository>()),
  );
  
  // TODO: Add other repositories and ViewModels
}
```

### 3. Update main.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service_locator.dart';
import 'theme/app_theme.dart';
import 'viewmodels/pass_viewmodel.dart';

void main() {
  setupServiceLocator();
  runApp(const BikeShareApp());
}

class BikeShareApp extends StatelessWidget {
  const BikeShareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<PassViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'Bike Share',
        theme: AppTheme.lightTheme,
        home: const PassSelectionScreen(),
      ),
    );
  }
}
```

### 4. Create UI with Provider
```dart
class PassSelectionScreen extends StatelessWidget {
  const PassSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Pass'),
      ),
      body: Consumer<PassViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == AppState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.state == AppState.error) {
            return Center(
              child: Text('Error: ${viewModel.errorMessage}'),
            );
          }
          
          return ListView(
            children: viewModel.passes
                .map((pass) => PassCard(pass: pass))
                .toList(),
          );
        },
      ),
    );
  }
}
```

---

## 🧪 Testing Your Setup

### Test 1: Verify Theme
```bash
# Run the app and check if colors/fonts are applied correctly
flutter run
```

### Test 2: Test Mock Repository
```dart
// In test file
void main() {
  test('MockPassRepository returns passes', () async {
    final repo = MockPassRepository();
    final passes = await repo.getPassesByUserId('user123');
    expect(passes, isNotEmpty);
  });
}
```

### Test 3: Test ViewModel
```dart
void main() {
  test('BikeViewModel loads bikes', () async {
    final mockRepo = MockBikeRepository();
    final viewModel = BikeViewModel(mockRepo);
    
    await viewModel.getBikesByStation('station1');
    
    expect(viewModel.state, AppState.success);
    expect(viewModel.bikes, isNotEmpty);
  });
}
```

---

## 📊 JIRA Task Template

### For Somnang
```
Task: Create Custom Button Widget
Description: Create reusable ElevatedButton using AppTheme
Files: lib/widgets/common/custom_button.dart
Acceptance Criteria:
- Uses AppColors.primary for background
- Uses AppSpacing.md for padding
- Uses AppTextStyles.buttonText for text style
- Supports loading state with spinner
```

### For Reyu
```
Task: Create PassViewModel
Description: Implement PassViewModel with mock repository
Files: lib/viewmodels/pass_viewmodel.dart
Acceptance Criteria:
- Handles loading/error/success states
- Calls MockPassRepository
- Updates UI through notifyListeners()
```

### For Elite
```
Task: Design Firebase Collections
Description: Create Firebase collections for bike sharing
Files: firebase/config
Acceptance Criteria:
- users/ collection created
- passes/ collection created
- stations/ collection created
- bikes/ collection created
- bookings/ collection created
```

---

## 📚 Key Files Reference

| File | Purpose | Owner |
|------|---------|-------|
| `lib/theme/app_theme.dart` | Material 3 theme | Somnang |
| `lib/models/pass.dart` | Pass data model | Reyu |
| `lib/dtos/pass_dto.dart` | Firebase DTO | Reyu |
| `lib/repositories/base/pass_repository.dart` | Abstract interface | Reyu |
| `lib/repositories/mock/mock_pass_repository.dart` | Mock impl | Reyu |
| `lib/repositories/firebase/firebase_pass_repository.dart` | Firebase impl | Elite |
| `lib/viewmodels/pass_viewmodel.dart` | ViewModel | Reyu |
| `lib/views/pass/pass_selection_screen.dart` | UI Screen | Somnang |
| `lib/service_locator.dart` | DI setup | Reyu |
| `lib/main.dart` | App entry | All |

---

## ✅ Checklist Before Jury

- [ ] All theme constants are used (no hard-coded values)
- [ ] All ViewModels have loading/error states
- [ ] Mock repositories work with mock data
- [ ] Firebase repositories connect to real data
- [ ] Provider setup works correctly
- [ ] DI container initializes properly
- [ ] All screens load without errors
- [ ] Tests pass (unit + integration)
- [ ] Code is clean and documented
- [ ] JIRA tasks are updated

---

## 🆘 Common Issues & Solutions

**Issue**: Import errors on architecture files
**Solution**: Make sure all directories are created and files exist

**Issue**: `GetIt` not found
**Solution**: Add `get_it: ^7.6.0` to pubspec.yaml and run `flutter pub get`

**Issue**: Provider not updating UI
**Solution**: Make sure to call `notifyListeners()` in ViewModel after state changes

**Issue**: Firebase collections not visible
**Solution**: Check Firebase console, ensure collections are created with test data

---

**Happy Coding! 🚀**

For questions, ask in the Telegram group or create JIRA tickets.

Team: Somnang, Reyu, Elite  
Date: April 17, 2026
