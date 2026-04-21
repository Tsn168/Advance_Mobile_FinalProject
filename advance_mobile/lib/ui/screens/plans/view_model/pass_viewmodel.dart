import 'package:flutter/foundation.dart';

import '../../../../config/app_constants.dart';
import '../../../../model/pass/pass.dart';
import '../../../../data/repositories/pass/pass_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';

class PassViewModel extends ChangeNotifier {
  PassViewModel(this._passRepository, this._userRepository);

  final IPassRepository _passRepository;
  final IUserRepository _userRepository;

  AppState _state = AppState.idle;
  String? _errorMessage;
  List<Pass> _availablePasses = [];
  List<Pass> _userPasses = [];
  Pass? _activePass;
  PassType? _selectedPassType;
  String _currentUserId = AppConstants.defaultUserId;

  AppState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Pass> get availablePasses => _availablePasses;
  List<Pass> get userPasses => _userPasses;
  Pass? get activePass => _activePass;
  PassType? get selectedPassType => _selectedPassType;
  String get currentUserId => _currentUserId;
  bool get hasActivePass => _activePass != null;

  Future<bool> canPurchasePass() async {
    final currentActivePass = await _passRepository.getActivePass(_currentUserId);
    _activePass = currentActivePass;
    return currentActivePass == null || currentActivePass.isExpired;
  }

  String getActivePassInfo() {
    final pass = _activePass;
    if (pass == null) {
      return 'No active pass.';
    }

    final month = pass.expiryDate.toLocal().month.toString().padLeft(2, '0');
    final day = pass.expiryDate.toLocal().day.toString().padLeft(2, '0');
    final year = pass.expiryDate.toLocal().year;
    return 'You already have an active ${pass.type.displayName} until $month/$day/$year.';
  }

  Future<void> initialize({String userId = AppConstants.defaultUserId}) async {
    _currentUserId = userId;
    await Future.wait([loadAvailablePasses(), loadUserPasses()]);
  }

  Future<void> loadAvailablePasses() async {
    try {
      _state = AppState.loading;
      _errorMessage = null;
      notifyListeners();

      _availablePasses = await _passRepository.getAllAvailablePasses();
      _state = AppState.success;
    } catch (error) {
      _state = AppState.error;
      _errorMessage = ErrorHandler.handleError(error);
    }
    notifyListeners();
  }

  Future<void> loadUserPasses() async {
    try {
      _state = AppState.loading;
      _errorMessage = null;
      notifyListeners();

      _userPasses = await _passRepository.getPassesByUserId(_currentUserId);
      _activePass = await _passRepository.getActivePass(_currentUserId);
      _state = AppState.success;
    } catch (error) {
      _state = AppState.error;
      _errorMessage = ErrorHandler.handleError(error);
    }
    notifyListeners();
  }

  void selectPassType(PassType passType) {
    _selectedPassType = passType;
    notifyListeners();
  }

  Future<bool> purchaseSelectedPass() async {
    final passType = _selectedPassType;
    if (passType == null) {
      _errorMessage = 'Please select a pass type first.';
      _state = AppState.error;
      notifyListeners();
      return false;
    }

    final allowed = await canPurchasePass();
    if (!allowed) {
      _errorMessage = getActivePassInfo();
      _state = AppState.error;
      notifyListeners();
      return false;
    }

    try {
      _state = AppState.loading;
      _errorMessage = null;
      notifyListeners();

      final currentActivePass = await _passRepository.getActivePass(_currentUserId);
      if (currentActivePass != null && !currentActivePass.isExpired) {
        _errorMessage = getActivePassInfo();
        _state = AppState.error;
        notifyListeners();
        return false;
      }

      final nowUtc = DateTime.now().toUtc();
      final expiryUtc = nowUtc.add(Duration(days: passType.durationDays));
      final createdPass = await _passRepository.createPass(
        Pass(
          id: '',
          userId: _currentUserId,
          type: passType,
          startDate: nowUtc,
          expiryDate: expiryUtc,
          isActive: true,
          price: _purchasePrice(passType),
          ridesUsed: 0,
          createdAt: nowUtc,
        ),
      );

      await _userRepository.updateActivePassId(_currentUserId, createdPass.id);

      _selectedPassType = null;
      await loadUserPasses();
      _state = AppState.success;
      notifyListeners();
      return true;
    } catch (error) {
      _state = AppState.error;
      _errorMessage = ErrorHandler.handleError(error);
      notifyListeners();
      return false;
    }
  }

  double _purchasePrice(PassType passType) {
    switch (passType) {
      case PassType.day:
        return 5.00;
      case PassType.monthly:
        return 25.00;
      case PassType.annual:
        return 150.00;
      case PassType.weekly:
        return passType.price;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AppState.error) {
      _state = AppState.idle;
    }
    notifyListeners();
  }
}
