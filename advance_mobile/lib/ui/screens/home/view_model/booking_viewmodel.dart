import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../../../services/error_handler.dart';

import '../../../../config/app_constants.dart';
import '../../../../data/repositories/bike/bike_repository.dart';
import '../../../../model/booking/booking.dart';
import '../../../../model/bike/bike.dart';
import '../../../../model/pass/pass.dart';
import '../../../../data/repositories/booking/booking_repository.dart';
import '../../../../data/repositories/pass/pass_repository.dart';
import '../../../../data/repositories/station/station_repository.dart';

enum BookingFlowStatus {
  idle,
  checkingPass,
  readyToBook,
  requiresPassSelection,
  booking,
  booked,
  failed,
}

class BookingViewModel extends ChangeNotifier {
  BookingViewModel(
    this._bookingRepository,
    this._passRepository,
    this._bikeRepository,
    this._stationRepository,
  );

  final IBookingRepository _bookingRepository;
  final IPassRepository _passRepository;
  final IBikeRepository _bikeRepository;
  final IStationRepository _stationRepository;

  AppState _state = AppState.idle;
  BookingFlowStatus _flowStatus = BookingFlowStatus.idle;
  String? _errorMessage;
  String _currentUserId = AppConstants.defaultUserId;
  Booking? _activeBooking;
  String? _selectedBikeId;
  String? _selectedStationId;
  int? _selectedSlotNumber;
  bool _isDisposed = false;
  StreamSubscription<Booking?>? _activeBookingSubscription;

  AppState get state => _state;
  BookingFlowStatus get flowStatus => _flowStatus;
  String? get errorMessage => _errorMessage;
  Booking? get activeBooking => _activeBooking;
  String get currentUserId => _currentUserId;
  bool get hasActiveBooking => _activeBooking != null;
  String? get selectedBikeId => _selectedBikeId;
  String? get selectedStationId => _selectedStationId;
  int? get selectedSlotNumber => _selectedSlotNumber;

  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> prepareBooking({
    required String bikeId,
    required String stationId,
    required int slotNumber,
  }) async {
    _selectedBikeId = bikeId;
    _selectedStationId = stationId;
    _selectedSlotNumber = slotNumber;

    _state = AppState.loading;
    _errorMessage = null;
    _flowStatus = BookingFlowStatus.checkingPass;
    _notifySafe();

    try {
      final hasPass = await _passRepository.hasActivePass(_currentUserId);
      _state = AppState.success;
      _flowStatus = hasPass
          ? BookingFlowStatus.readyToBook
          : BookingFlowStatus.requiresPassSelection;
      if (!hasPass) {
        _errorMessage = 'No active pass. Please select a pass before booking.';
      }
    } catch (error) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = ErrorHandlerService.handleError(error);
    }
    _notifySafe();
  }

  Future<bool> confirmBooking() async {
    final bikeId = _selectedBikeId;
    final stationId = _selectedStationId;
    final slotNumber = _selectedSlotNumber;

    if (bikeId == null || stationId == null || slotNumber == null) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = 'No bike selected for booking.';
      _notifySafe();
      return false;
    }

    _flowStatus = BookingFlowStatus.booking;
    _notifySafe();

    final success = await bookBike(
      bikeId: bikeId,
      stationId: stationId,
      slotNumber: slotNumber,
    );

    if (success) {
      _flowStatus = BookingFlowStatus.booked;
      _notifySafe();
      return true;
    }

    if (_flowStatus != BookingFlowStatus.requiresPassSelection) {
      _flowStatus = BookingFlowStatus.failed;
      _notifySafe();
    }
    return false;
  }

  Future<bool> purchaseSingleTicketAndBook() async {
    final bikeId = _selectedBikeId;
    if (bikeId == null || _selectedStationId == null || _selectedSlotNumber == null) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = 'No bike selected for booking.';
      _notifySafe();
      return false;
    }

    try {
      _state = AppState.loading;
      _errorMessage = null;
      _flowStatus = BookingFlowStatus.booking;
      _notifySafe();

      final hasPass = await _passRepository.hasActivePass(_currentUserId);
      if (!hasPass) {
        final now = DateTime.now();
        await _passRepository.createPass(
          Pass(
            id: '',
            userId: _currentUserId,
            type: PassType.day,
            startDate: now,
            expiryDate: now.add(const Duration(hours: 2)),
            isActive: true,
            price: 2.99,
            ridesUsed: 0,
            createdAt: now,
          ),
        );
      }

      return await confirmBooking();
    } catch (error) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = ErrorHandlerService.handleError(error);
      _notifySafe();
      return false;
    }
  }

  Future<void> initialize({String userId = AppConstants.defaultUserId}) async {
    _currentUserId = userId;
    try {
      await _activeBookingSubscription?.cancel();
      _activeBooking = await _bookingRepository.getActiveBookingByUserId(
        userId,
      );
      _notifySafe();

      _activeBookingSubscription = _bookingRepository
          .watchActiveBooking(userId)
          .listen(
            (booking) {
              _activeBooking = booking;
              if (booking == null && _flowStatus == BookingFlowStatus.booked) {
                _flowStatus = BookingFlowStatus.idle;
              }
              _notifySafe();
            },
            onError: (Object error) {
              _state = AppState.error;
              _flowStatus = BookingFlowStatus.failed;
              _errorMessage = ErrorHandlerService.handleError(error);
              _notifySafe();
            },
          );
    } catch (error) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = ErrorHandlerService.handleError(error);
      _notifySafe();
    }
  }

  Future<bool> bookBike({
    required String bikeId,
    required String stationId,
    required int slotNumber,
  }) async {
    _selectedBikeId = bikeId;
    _selectedStationId = stationId;
    _selectedSlotNumber = slotNumber;

    _state = AppState.loading;
    _errorMessage = null;
    _flowStatus = BookingFlowStatus.checkingPass;
    _notifySafe();

    try {
      final hasPass = await _passRepository.hasActivePass(_currentUserId);
      if (!hasPass) {
        _state = AppState.idle;
        _flowStatus = BookingFlowStatus.requiresPassSelection;
        _errorMessage = 'No active pass. Please select a pass before booking.';
        _notifySafe();
        return false;
      }

      _flowStatus = BookingFlowStatus.booking;
      _notifySafe();

      final bike = await _bikeRepository.getBikeById(bikeId);
      if (bike == null || bike.status != BikeStatus.available) {
        _state = AppState.error;
        _flowStatus = BookingFlowStatus.failed;
        _errorMessage =
            'This bike is no longer available. Please refresh the bike list and go back to station details to choose another bike.';
        _notifySafe();
        return false;
      }

      final now = DateTime.now();
      final createdBooking = await _bookingRepository.createBooking(
        Booking(
          id: '',
          userId: _currentUserId,
          bikeId: bikeId,
          stationId: stationId,
          slotNumber: slotNumber,
          bookingDate: now,
          status: BookingStatus.active,
        ),
      );

      try {
        await _bikeRepository.updateBikeStatus(bikeId, BikeStatus.booked);
      } catch (_) {
        await _attemptRollbackBookingCreation(createdBooking.id);
        rethrow;
      }

      try {
        final station = await _stationRepository.getStationById(stationId);
        final nextAvailability = station == null
            ? 0
            : (station.availableBikes > 0 ? station.availableBikes - 1 : 0);

        await _stationRepository.updateStationAvailability(
          stationId,
          nextAvailability,
        );
      } catch (_) {
        await _attemptRollbackBookingCreation(createdBooking.id);
        await _attemptRollbackBikeStatus(bikeId);
        rethrow;
      }

      _activeBooking = createdBooking;
      _state = AppState.success;
      _flowStatus = BookingFlowStatus.booked;
      _notifySafe();
      return true;
    } catch (error) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = ErrorHandlerService.handleError(error);
      _notifySafe();
      return false;
    }
  }

  Future<void> _attemptRollbackBookingCreation(String bookingId) async {
    try {
      await _bookingRepository.updateBookingStatus(bookingId, BookingStatus.cancelled);
    } catch (_) {
      // Best-effort rollback.
    }
  }

  Future<void> _attemptRollbackBikeStatus(String bikeId) async {
    try {
      await _bikeRepository.updateBikeStatus(bikeId, BikeStatus.available);
    } catch (_) {
      // Best-effort rollback.
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
      _notifySafe();

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
    _notifySafe();
  }

  Future<void> cancelCurrentBooking() async {
    final booking = _activeBooking;
    if (booking == null) {
      return;
    }

    try {
      _state = AppState.loading;
      _errorMessage = null;
      _notifySafe();

      await _bookingRepository.cancelBooking(booking.id);
      _activeBooking = null;
      _state = AppState.success;
      _flowStatus = BookingFlowStatus.idle;
    } catch (error) {
      _state = AppState.error;
      _flowStatus = BookingFlowStatus.failed;
      _errorMessage = ErrorHandlerService.handleError(error);
    }
    _notifySafe();
  }

  void clearBookingPrompt() {
    if (_flowStatus == BookingFlowStatus.requiresPassSelection) {
      _flowStatus = BookingFlowStatus.idle;
      if (_state == AppState.error) {
        _state = AppState.idle;
      }
      _errorMessage = null;
      _notifySafe();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    final subscription = _activeBookingSubscription;
    _activeBookingSubscription = null;
    if (subscription != null) {
      unawaited(
        subscription.cancel().catchError((Object _) {
          // Ignore cancellation race conditions during teardown.
        }),
      );
    }
    super.dispose();
  }
}
