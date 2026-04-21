import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../config/app_constants.dart';
import '../../../../data/repositories/booking/booking_repository.dart';
import '../../../../data/repositories/pass/pass_repository.dart';
import '../../../../model/booking/booking.dart';
import '../../../../model/pass/pass.dart';

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
  final IBookingRepository _bookingRepository;
  final IPassRepository _passRepository;

  BookingViewModel(this._bookingRepository, this._passRepository);

  AppState _state = AppState.idle;
  AppState get state => _state;

  BookingFlowStatus _flowStatus = BookingFlowStatus.idle;
  BookingFlowStatus get flowStatus => _flowStatus;

  Booking? _activeBooking;
  Booking? get activeBooking => _activeBooking;

  String? _selectedBikeId;
  String? get selectedBikeId => _selectedBikeId;

  String? _selectedStationId;
  String? get selectedStationId => _selectedStationId;

  int? _selectedSlotNumber;
  int? get selectedSlotNumber => _selectedSlotNumber;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _bookingSubscription;
  String? _currentUserId;

  Future<void> initialize({String userId = 'user_reyu'}) async {
    _currentUserId = userId;
    await loadActiveBooking(userId);
    _listenToActiveBooking(userId);
  }

  Future<void> loadActiveBooking(String userId) async {
    _state = AppState.loading;
    notifyListeners();
    try {
      _activeBooking = await _bookingRepository.getActiveBookingByUserId(userId);
      _errorMessage = null;
      _state = AppState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
    } finally {
      notifyListeners();
    }
  }

  void _listenToActiveBooking(String userId) {
    _bookingSubscription?.cancel();
    _bookingSubscription = _bookingRepository.watchActiveBooking(userId).listen((booking) {
      _activeBooking = booking;
      if (booking == null && _flowStatus == BookingFlowStatus.booked) {
        _flowStatus = BookingFlowStatus.idle;
      }
      notifyListeners();
    });
  }

  Future<void> prepareBooking({
    required String bikeId,
    required String stationId,
    required int slotNumber,
  }) async {
    _selectedBikeId = bikeId;
    _selectedStationId = stationId;
    _selectedSlotNumber = slotNumber;
    _flowStatus = BookingFlowStatus.checkingPass;
    notifyListeners();

    final hasPass = await _passRepository.hasActivePass(_currentUserId ?? 'user_reyu');
    if (hasPass) {
      _flowStatus = BookingFlowStatus.readyToBook;
      _errorMessage = null;
    } else {
      _flowStatus = BookingFlowStatus.requiresPassSelection;
      _errorMessage = 'No active pass. Please select a pass to continue.';
    }
    notifyListeners();
  }

  Future<bool> bookBike({
    required String bikeId,
    required String stationId,
    required int slotNumber,
  }) async {
    await prepareBooking(bikeId: bikeId, stationId: stationId, slotNumber: slotNumber);
    if (_flowStatus == BookingFlowStatus.readyToBook) {
      return await confirmBooking();
    }
    return false;
  }

  Future<bool> confirmBooking() async {
    if (_selectedBikeId == null || _selectedStationId == null || _selectedSlotNumber == null) {
      _errorMessage = 'No bike selected';
      _flowStatus = BookingFlowStatus.failed;
      notifyListeners();
      return false;
    }

    _flowStatus = BookingFlowStatus.booking;
    notifyListeners();

    try {
      final newBooking = Booking(
        id: 'book_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUserId ?? 'user_reyu',
        bikeId: _selectedBikeId!,
        stationId: _selectedStationId!,
        slotNumber: _selectedSlotNumber!,
        bookingDate: DateTime.now(),
        status: BookingStatus.active,
      );
      _activeBooking = await _bookingRepository.createBooking(newBooking);
      _flowStatus = BookingFlowStatus.booked;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _flowStatus = BookingFlowStatus.failed;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> purchaseSingleTicketAndBook() async {
    if (_selectedBikeId == null || _selectedStationId == null || _selectedSlotNumber == null) {
      return false;
    }

    _flowStatus = BookingFlowStatus.booking;
    notifyListeners();

    try {
      // Purchase a day pass (simplified)
      final now = DateTime.now();
      final pass = Pass(
        id: 'pass_${now.millisecondsSinceEpoch}',
        userId: _currentUserId ?? 'user_reyu',
        type: PassType.day,
        startDate: now,
        expiryDate: now.add(const Duration(days: 1)),
        isActive: true,
        price: PassType.day.price,
      );
      await _passRepository.createPass(pass);
      
      // Then book
      _flowStatus = BookingFlowStatus.readyToBook;
      return await confirmBooking();
    } catch (e) {
      _errorMessage = e.toString();
      _flowStatus = BookingFlowStatus.failed;
      notifyListeners();
      return false;
    }
  }

  Future<void> cancelCurrentBooking() async {
    if (_activeBooking == null) return;
    
    _state = AppState.loading;
    notifyListeners();

    try {
      await _bookingRepository.cancelBooking(_activeBooking!.id);
      _activeBooking = null;
      _flowStatus = BookingFlowStatus.idle;
      _state = AppState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> completeCurrentBooking({
    required double rideDistance,
    required int rideDuration,
  }) async {
    if (_activeBooking == null) return;

    _state = AppState.loading;
    notifyListeners();

    try {
      await _bookingRepository.completeBooking(
        _activeBooking!.id,
        returnDate: DateTime.now(),
        rideDistance: rideDistance,
        rideDuration: rideDuration,
      );
      _activeBooking = null;
      _flowStatus = BookingFlowStatus.idle;
      _state = AppState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
    } finally {
      notifyListeners();
    }
  }

  bool get hasActiveBooking => _activeBooking != null;

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }
}
