import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../config/app_constants.dart' as constants;
import '../../../../data/repositories/booking/booking_repository.dart';
import '../../../../data/repositories/pass/pass_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../model/booking/booking.dart';
import '../../../../model/pass/pass.dart';
import '../../../../model/user/user.dart';
import '../../../../services/error_handler.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(
    this._userRepository,
    this._passRepository,
    this._bookingRepository,
  );

  final IUserRepository _userRepository;
  final IPassRepository _passRepository;
  final IBookingRepository _bookingRepository;

  constants.AppState _state = constants.AppState.idle;
  String? _errorMessage;
  User? _user;
  Pass? _activePass;
  List<Booking> _bookingHistory = [];
  StreamSubscription<Pass?>? _passSubscription;
  StreamSubscription<List<Booking>>? _bookingsSubscription;

  constants.AppState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  Pass? get activePass => _activePass;
  List<Booking> get bookingHistory => _bookingHistory;

  /// Statistics for the circle graph
  int get totalRides => _bookingHistory.length;
  double get totalDistance => _bookingHistory.fold(0.0, (sum, b) => sum + (b.rideDistance ?? 0));
  int get totalDurationMinutes => _bookingHistory.fold(0, (sum, b) => sum + (b.rideDuration ?? 0));

  Future<void> initialize(String userId) async {
    _state = constants.AppState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch initial data
      final results = await Future.wait([
        _userRepository.getUserById(userId),
        _passRepository.getActivePass(userId),
        _bookingRepository.getBookingHistory(userId),
      ]);

      _user = results[0] as User?;
      _activePass = results[1] as Pass?;
      _bookingHistory = results[2] as List<Booking>;

      _state = constants.AppState.success;
      notifyListeners();

      // Listen for pass changes
      _passSubscription?.cancel();
      _passSubscription = _passRepository.watchActivePass(userId).listen((pass) {
        _activePass = pass;
        notifyListeners();
      });

      // Listen for booking history changes
      _bookingsSubscription?.cancel();
      _bookingsSubscription =
          _bookingRepository.watchBookingsByUserId(userId).listen((bookings) {
        _bookingHistory = bookings;
        notifyListeners();
      });
    } catch (error) {
      _state = constants.AppState.error;
      _errorMessage = ErrorHandlerService.handleError(error);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_user == null) return;
    await initialize(_user!.id);
  }

  @override
  void dispose() {
    _passSubscription?.cancel();
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}
