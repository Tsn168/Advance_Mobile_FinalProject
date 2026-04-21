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

  void goToMap() => setTab(0);
  void goToPlans() => setTab(1);
  void goToProfile() => setTab(2);
}
