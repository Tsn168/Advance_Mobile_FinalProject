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
    return currentActivePass == null || currentActivePass.isExpired;
  }

  String getActivePassInfo() {
    final activePass = _activePass;
    if (activePass == null) {
      return 'No active pass';
    }

    final month = activePass.expiryDate.month.toString().padLeft(2, '0');
    final day = activePass.expiryDate.day.toString().padLeft(2, '0');
    final date = '$month/$day/${activePass.expiryDate.year}';
    return '${activePass.type.displayName} active until $date';
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

    try {
      _state = AppState.loading;
      _errorMessage = null;
      notifyListeners();

      final currentActivePass = await _passRepository.getActivePass(
        _currentUserId,
      );
      if (currentActivePass != null) {
        final month = currentActivePass.expiryDate.month.toString().padLeft(2, '0');
        final day = currentActivePass.expiryDate.day.toString().padLeft(2, '0');
        _state = AppState.error;
        _errorMessage =
            'You already have an active ${currentActivePass.type.displayName} pass valid until $month/$day/${currentActivePass.expiryDate.year}.';
        notifyListeners();
        return false;
      }

      final now = DateTime.now();
      final createdPass = await _passRepository.createPass(
        Pass(
          id: '',
          userId: _currentUserId,
          type: passType,
          startDate: now,
          expiryDate: now.add(Duration(days: passType.durationDays)),
          isActive: true,
          price: passType.price,
          ridesUsed: 0,
          createdAt: now,
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

  void clearError() {
    _errorMessage = null;
    if (_state == AppState.error) {
      _state = AppState.idle;
    }
    notifyListeners();
  }
}
