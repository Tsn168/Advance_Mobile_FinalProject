import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../config/app_constants.dart';
import '../../../../model/bike/bike.dart';
import '../../../../data/repositories/bike/bike_repository.dart';

class BikeViewModel extends ChangeNotifier {
  BikeViewModel(this._bikeRepository);

  final IBikeRepository _bikeRepository;

  AppState _state = AppState.idle;
  String? _errorMessage;
  List<Bike> _bikes = [];
  String? _stationId;
  StreamSubscription<List<Bike>>? _bikesSubscription;

  AppState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Bike> get bikes => _bikes;
  String? get stationId => _stationId;

  List<Bike> get availableBikes {
    return _bikes.where((bike) => bike.status == BikeStatus.available).toList();
  }

  Future<void> loadBikesByStation(String stationId) async {
    _stationId = stationId;
    _state = AppState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _bikesSubscription?.cancel();
      _bikes = await _bikeRepository.getBikesByStation(stationId);
      _state = AppState.success;
      notifyListeners();

      _bikesSubscription = _bikeRepository
          .watchBikesByStation(stationId)
          .listen(
            (bikes) {
              _bikes = bikes;
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

  Future<void> refresh() async {
    if (_stationId == null) {
      return;
    }
    try {
      _state = AppState.loading;
      _errorMessage = null;
      notifyListeners();

      _bikes = await _bikeRepository.getBikesByStation(_stationId!);
      _state = AppState.success;
    } catch (error) {
      _state = AppState.error;
      _errorMessage = ErrorHandler.handleError(error);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _bikesSubscription?.cancel();
    super.dispose();
  }
}
