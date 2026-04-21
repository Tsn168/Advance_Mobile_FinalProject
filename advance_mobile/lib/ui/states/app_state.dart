import 'package:flutter/foundation.dart';

import '../../model/user/user.dart';

/// Global app state for user authentication and session
class GlobalAppState extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isDarkMode = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isDarkMode => _isDarkMode;
  String get userId => _currentUser?.id ?? '';

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setUser(User user) {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
