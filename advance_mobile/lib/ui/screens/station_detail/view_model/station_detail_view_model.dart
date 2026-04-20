import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../config/app_constants.dart';
import '../../../../data/repositories/bike/bike_repository.dart';
import '../../../../data/repositories/station/station_repository.dart';
import '../../../../model/bike/bike.dart';
import '../../../../model/station/station.dart';

class StationDetailViewModel extends ChangeNotifier {
  StationDetailViewModel(this._bikeRepository, this._stationRepository);

  final IBikeRepository _bikeRepository;
  final IStationRepository _stationRepository;

  AppState _state = AppState.idle;
  String? _errorMessage;
  Station? _station;
  List<Bike> _bikes = [];
  Bike? _selectedBike;
  StreamSubscription<List<Bike>>? _bikesSubscription;

  AppState get state => _state;
  String? get errorMessage => _errorMessage;
  Station? get station => _station;
  List<Bike> get bikes => _bikes;
  List<Bike> get availableBikes =>
      _bikes.where((bike) => bike.isAvailable).toList();
  List<Bike> get unavailableBikes =>
      _bikes.where((bike) => !bike.isAvailable).toList();
  Bike? get selectedBike => _selectedBike;
  int get totalSlots => _station?.totalSlots ?? 0;
  int get occupiedSlots => _bikes.length;
  int get emptySlots {
    final slots = totalSlots - occupiedSlots;
    return slots < 0 ? 0 : slots;
  }

  Future<void> loadStationDetails(String stationId) async {
    _state = AppState.loading;
    _errorMessage = null;
    _selectedBike = null;
    notifyListeners();

    try {
      await _bikesSubscription?.cancel();

      final station = await _stationRepository.getStationById(stationId);
      if (station == null) {
        throw Exception('Station not found');
      }

      _station = station;
      _bikes = await _bikeRepository.getBikesByStation(stationId);
      _syncSelectedBike();

      _state = AppState.success;
      notifyListeners();

      _bikesSubscription = _bikeRepository.watchBikesByStation(stationId).listen(
        (bikes) {
          _bikes = bikes;
          _syncSelectedBike();
          _state = AppState.success;
          notifyListeners();
        },
        onError: (Object error) {
          _state = AppState.error;
          _errorMessage = ErrorHandler.handleError(error);
          notifyListeners();
        },
      );
    } catch (error) {
      _state = AppState.error;
      _errorMessage = ErrorHandler.handleError(error);
      notifyListeners();
    }
  }

  void selectBike(String bikeId) {
    try {
      _selectedBike = _bikes.firstWhere((bike) => bike.id == bikeId);
      _errorMessage = null;
    } catch (_) {
      _selectedBike = null;
      _errorMessage = 'Selected bike is no longer available';
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedBike = null;
    notifyListeners();
  }

  Future<void> refreshBikes() async {
    final stationId = _station?.id;
    if (stationId == null) {
      _state = AppState.error;
      _errorMessage = 'Station is not loaded';
      notifyListeners();
      return;
    }

    try {
      _state = AppState.loading;
      _errorMessage = null;
      notifyListeners();

      _bikes = await _bikeRepository.getBikesByStation(stationId);
      _syncSelectedBike();
      _state = AppState.success;
    } catch (error) {
      _state = AppState.error;
      _errorMessage = ErrorHandler.handleError(error);
    }
    notifyListeners();
  }

  void _syncSelectedBike() {
    if (_selectedBike == null) {
      return;
    }

    try {
      _selectedBike = _bikes.firstWhere((bike) => bike.id == _selectedBike!.id);
    } catch (_) {
      _selectedBike = null;
    }
  }

  @override
  void dispose() {
    _bikesSubscription?.cancel();
    super.dispose();
  }
}
