import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_env.dart';
import 'service_locator.dart';
import 'services/google_maps_js_loader.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/map/view_model/booking_viewmodel.dart';
import 'ui/screens/map/view_model/bike_viewmodel.dart';
import 'ui/screens/map/view_model/map_viewmodel.dart';
import 'ui/screens/plans/view_model/pass_viewmodel.dart';
import 'ui/screens/profile/view_model/profile_viewmodel.dart';
import 'ui/states/app_state.dart';
import 'ui/states/navigation_state.dart';
import 'ui/screens/splash/prelaunch_splash_screen.dart';
import 'ui/screens/map/map_screen.dart';
import 'ui/screens/plans/plans_screen.dart';
import 'ui/screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  // Firebase initialization disabled for UI development.
  // ELITE team will configure and enable this when backend is ready.
  // await FirebaseService.initialize();
  await ensureGoogleMapsJsLoaded(apiKey: AppEnv.googleMapsApiKey);
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global States (shared across entire app)
        ChangeNotifierProvider(create: (_) => getIt<GlobalAppState>()),
        ChangeNotifierProvider(create: (_) => getIt<NavigationState>()),
        // Feature ViewModels
        ChangeNotifierProvider(
          create: (_) => getIt<PassViewModel>()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<MapViewModel>()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => getIt<BikeViewModel>()),
        ChangeNotifierProvider(
          create: (_) => getIt<BookingViewModel>()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<ProfileViewModel>()..initialize('user_reyu'),
        ),
      ],
      child: Consumer<GlobalAppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Bike Sharing App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: PrelaunchSplashScreen(nextScreen: MainNavigationScreen()),
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationState = context.watch<NavigationState>();

    return Scaffold(
      body: IndexedStack(
        index: navigationState.currentTabIndex,
        children: [
          MapScreen(
            key: const ValueKey('MapScreen'),
            onNavigateToPlans: () => navigationState.goToPlans(),
          ),
          const PlansScreen(key: ValueKey('PlansScreen')),
          const ProfileScreen(key: ValueKey('ProfileScreen')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationState.currentTabIndex,
        onTap: navigationState.setTab,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Plans',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
