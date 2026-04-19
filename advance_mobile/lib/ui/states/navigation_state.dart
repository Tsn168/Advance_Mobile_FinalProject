import 'package:flutter/foundation.dart';

/// Global navigation state for managing tab navigation across the app
class NavigationState extends ChangeNotifier {
  int _currentTabIndex = 0;

  int get currentTabIndex => _currentTabIndex;

  void setTab(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  void goToHome() => setTab(0);
  void goToMap() => setTab(1);
  void goToPlans() => setTab(2);
  void goToProfile() => setTab(3);
}
