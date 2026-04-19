import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'service_locator.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/home/view_model/booking_viewmodel.dart';
import 'ui/screens/map/view_model/bike_viewmodel.dart';
import 'ui/screens/map/view_model/map_viewmodel.dart';
import 'ui/screens/plans/view_model/pass_viewmodel.dart';
import 'ui/states/app_state.dart';
import 'ui/states/navigation_state.dart';
import 'ui/screens/splash/prelaunch_splash_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/map/map_screen.dart';
import 'ui/screens/plans/plans_screen.dart';
import 'ui/screens/profile/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global States (shared across entire app)
        ChangeNotifierProvider(
          create: (_) => getIt<AppState>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<NavigationState>(),
        ),
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
      ],
      child: MaterialApp(
        title: 'Bike Sharing App',
        theme: AppTheme.lightTheme,
        home: const PrelaunchSplashScreen(nextScreen: MainNavigationScreen()),
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
          HomeScreen(
            onNavigateToMap: () => navigationState.goToMap(),
            onNavigateToPlans: () => navigationState.goToPlans(),
          ),
          MapScreen(onNavigateToPlans: () => navigationState.goToPlans()),
          const PlansScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationState.currentTabIndex,
        onTap: navigationState.setTab,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
