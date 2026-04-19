import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../config/app_constants.dart';
import '../../../../model/booking/booking.dart';
import '../../../../data/repositories/booking/booking_repository.dart';
import '../../../../data/repositories/pass/pass_repository.dart';
import '../../../../services/error_handler.dart';

enum BookingFlowStatus {
  idle,
  checkingPass,
  requiresPassSelection,
  booking,
  booked,
  failed,
}

class BookingViewModel extends ChangeNotifier {
  BookingViewModel(this._bookingRepository, this._passRepository);

  final IBookingRepository _bookingRepository;
  final IPassRepository _passRepository;

  AppState _state = AppState.idle;
  BookingFlowStatus _flowStatus = BookingFlowStatus.idle;
  String? _errorMessage;
  String _currentUserId = AppConstants.defaultUserId;
  Booking? _activeBooking;
  StreamSubscription<Booking?>? _activeBookingSubscription;

  AppState get state => _state;
  BookingFlowStatus get flowStatus => _flowStatus;
  String? get errorMessage => _errorMessage;
  Booking? get activeBooking => _activeBooking;
  String get currentUserId => _currentUserId;
  bool get hasActiveBooking => _activeBooking != null;

  Future<void> initialize({String userId = AppConstants.defaultUserId}) async {
    _currentUserId = userId;
    try {
      await _activeBookingSubscription?.cancel();
      _activeBooking = await _bookingRepository.getActiveBookingByUserId(
        userId,
      );
      notifyListeners();

      _activeBookingSubscription = _bookingRepository
          .watchActiveBooking(userId)
          .listen(
            (booking) {
              _activeBooking = booking;
              if (booking == null && _flowStatus == BookingFlowStatus.booked) {
                _flowStatus = BookingFlowStatus.idle;
              }
              notifyListeners();
            },
            onError: (Object error) {
              _state = AppState.error;
              _flowStatus = BookingFlowStatus.failed;
              _errorMessage = ErrorHandlerService.handleError(error);
              notifyListeners();
            },
          );
    } catch (error) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = ErrorHandlerService.handleError(error);
      notifyListeners();
    }
  }

  Future<bool> bookBike({
    required String bikeId,
    required String stationId,
    required int slotNumber,
  }) async {
    _state = AppState.loading;
    _errorMessage = null;
    _flowStatus = BookingFlowStatus.checkingPass;
    notifyListeners();

    try {
      final hasPass = await _passRepository.hasActivePass(_currentUserId);
      if (!hasPass) {
        _state = AppState.idle;
        _flowStatus = BookingFlowStatus.requiresPassSelection;
        _errorMessage = 'No active pass. Please select a pass before booking.';
        notifyListeners();
        return false;
      }

      _flowStatus = BookingFlowStatus.booking;
      notifyListeners();

      final booking = await _bookingRepository.createBooking(
        Booking(
          id: '',
          userId: _currentUserId,
          bikeId: bikeId,
          stationId: stationId,
          slotNumber: slotNumber,
          bookingDate: DateTime.now(),
          status: BookingStatus.active,
        ),
      );

      _activeBooking = booking;
      _state = AppState.success;
      _flowStatus = BookingFlowStatus.booked;
      notifyListeners();
      return true;
    } catch (error) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = ErrorHandlerService.handleError(error);
      notifyListeners();
      return false;
    }
  }

  Future<void> completeCurrentBooking({
    required double rideDistance,
    required int rideDuration,
  }) async {
    final booking = _activeBooking;
    if (booking == null) {
      return;
    }

    try {
      _state = AppState.loading;
      _errorMessage = null;
      notifyListeners();

      await _bookingRepository.completeBooking(
        booking.id,
        returnDate: DateTime.now(),
        rideDistance: rideDistance,
        rideDuration: rideDuration,
      );

      _activeBooking = null;
      _state = AppState.success;
      _flowStatus = BookingFlowStatus.idle;
    } catch (error) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = ErrorHandlerService.handleError(error);
    }
    notifyListeners();
  }

  Future<void> cancelCurrentBooking() async {
    final booking = _activeBooking;
    if (booking == null) {
      return;
    }

    try {
      _state = AppState.loading;
      _errorMessage = null;
      notifyListeners();

      await _bookingRepository.cancelBooking(booking.id);
      _activeBooking = null;
      _state = AppState.success;
      _flowStatus = BookingFlowStatus.idle;
    } catch (error) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = ErrorHandler.handleError(error);
    }
    notifyListeners();
  }

  void clearBookingPrompt() {
    if (_flowStatus == BookingFlowStatus.requiresPassSelection) {
      _flowStatus = BookingFlowStatus.idle;
      if (_state == AppState.error) {
        _state = AppState.idle;
      }
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _activeBookingSubscription?.cancel();
    super.dispose();
  }
}
