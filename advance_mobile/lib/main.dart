import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'service_locator.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/home/view_model/booking_viewmodel.dart';
import 'ui/screens/map/view_model/bike_viewmodel.dart';
import 'ui/screens/map/view_model/map_viewmodel.dart';
import 'ui/screens/plans/view_model/pass_viewmodel.dart';
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

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentTabIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  List<Widget> get _tabScreens {
    return [
      HomeScreen(
        onNavigateToMap: () => _goToTab(1),
        onNavigateToPlans: () => _goToTab(2),
      ),
      MapScreen(onNavigateToPlans: () => _goToTab(2)),
      const PlansScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentTabIndex, children: _tabScreens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: _goToTab,
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
