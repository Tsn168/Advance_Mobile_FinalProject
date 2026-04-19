import 'package:flutter/foundation.dart';

import '../../model/user/user.dart';

/// Global app state for user authentication and session
class AppState extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String get userId => _currentUser?.id ?? '';

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
