# Global States - UI Layer

## Overview

The `ui/states/` folder contains global app-wide state management classes that are shared across multiple screens.

## Structure

```
lib/ui/states/
├── app_state.dart          # User authentication & session state
└── navigation_state.dart   # Global navigation state
```

## Global States

### 1. AppState (`app_state.dart`)

**Purpose:** Manages user authentication and session across the entire app.

**Properties:**
- `currentUser` - Currently logged-in user
- `isAuthenticated` - Authentication status
- `userId` - Current user ID

**Methods:**
- `setUser(User user)` - Set authenticated user
- `logout()` - Clear user session

**Usage:**
```dart
// Access in any screen
final appState = context.watch<AppState>();
if (appState.isAuthenticated) {
  // Show authenticated content
}

// Update state
context.read<AppState>().setUser(user);
```

### 2. NavigationState (`navigation_state.dart`)

**Purpose:** Manages bottom navigation tab state globally.

**Properties:**
- `currentTabIndex` - Current active tab index

**Methods:**
- `setTab(int index)` - Set active tab
- `goToHome()` - Navigate to home tab
- `goToMap()` - Navigate to map tab
- `goToPlans()` - Navigate to plans tab
- `goToProfile()` - Navigate to profile tab

**Usage:**
```dart
// Access in any screen
final navState = context.watch<NavigationState>();

// Navigate to different tab
context.read<NavigationState>().goToPlans();
```

## Why Global States?

### Separation of Concerns
- **ViewModels** - Feature-specific business logic
- **Global States** - App-wide shared state

### Benefits
1. **Centralized State** - Single source of truth for app-wide data
2. **Easy Access** - Any screen can access global state via Provider
3. **Decoupled Navigation** - Screens don't need callbacks for navigation
4. **Testable** - Global states are pure Dart classes

## Registration

Global states are registered in `service_locator.dart` as **Lazy Singletons**:

```dart
// Register Global States (Singleton - shared across app)
getIt.registerLazySingleton<AppState>(() => AppState());
getIt.registerLazySingleton<NavigationState>(() => NavigationState());
```

And provided in `main.dart`:

```dart
MultiProvider(
  providers: [
    // Global States
    ChangeNotifierProvider(create: (_) => getIt<AppState>()),
    ChangeNotifierProvider(create: (_) => getIt<NavigationState>()),
    // Feature ViewModels
    ChangeNotifierProvider(create: (_) => getIt<PassViewModel>()..initialize()),
    // ...
  ],
  child: MaterialApp(...),
)
```

## Example: Using NavigationState

**Before (with callbacks):**
```dart
HomeScreen(
  onNavigateToMap: () => _goToTab(1),
  onNavigateToPlans: () => _goToTab(2),
)
```

**After (with global state):**
```dart
// In HomeScreen
ElevatedButton(
  onPressed: () => context.read<NavigationState>().goToMap(),
  child: Text('View Map'),
)
```

## Adding New Global States

1. Create new state file in `lib/ui/states/`
2. Extend `ChangeNotifier`
3. Register in `service_locator.dart`
4. Add to `MultiProvider` in `main.dart`

Example:
```dart
// lib/ui/states/theme_state.dart
class ThemeState extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
```

## Best Practices

### Use Global States For:
- ✅ User authentication/session
- ✅ App-wide navigation
- ✅ Theme/locale settings
- ✅ Network connectivity status
- ✅ App configuration

### Use ViewModels For:
- ✅ Feature-specific business logic
- ✅ Screen-specific state
- ✅ Data fetching for a feature
- ✅ Form validation

## Architecture Flow

```
Screen (View)
    ↓
    ├─→ Global State (app-wide data)
    │   └─→ AppState, NavigationState
    │
    └─→ ViewModel (feature logic)
        └─→ Repository → Model
```

## Summary

Global states provide a clean way to manage app-wide state that's shared across multiple screens, keeping your architecture organized and maintainable.
