import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../config/app_constants.dart';
import '../../../../model/station/station.dart';
import '../../../../data/repositories/station/station_repository.dart';

class MapViewModel extends ChangeNotifier {
  MapViewModel(this._stationRepository);

  final IStationRepository _stationRepository;

  AppState _state = AppState.idle;
  String? _errorMessage;
  List<Station> _stations = [];
  Station? _selectedStation;
  StreamSubscription<List<Station>>? _stationsSubscription;

  AppState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Station> get stations => _stations;
  Station? get selectedStation => _selectedStation;

  Future<void> initialize() async {
    _state = AppState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _stationsSubscription?.cancel();
      _stations = await _stationRepository.getAllStations();
      _state = AppState.success;
      notifyListeners();

      _stationsSubscription = _stationRepository.watchAllStations().listen(
        (stations) {
          _stations = stations;

          if (_selectedStation != null) {
            final selected = stations.where((station) {
              return station.id == _selectedStation!.id;
            });
            if (selected.isNotEmpty) {
              _selectedStation = selected.first;
            }
          }

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

  Future<void> refreshStations() async {
    try {
      _state = AppState.loading;
      _errorMessage = null;
      notifyListeners();

      _stations = await _stationRepository.getAllStations();
      _state = AppState.success;
    } catch (error) {
      _state = AppState.error;
      _errorMessage = ErrorHandler.handleError(error);
    }
    notifyListeners();
  }

  void selectStation(String stationId) {
    try {
      _selectedStation = _stations.firstWhere(
        (station) => station.id == stationId,
      );
    } catch (_) {
      _selectedStation = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _stationsSubscription?.cancel();
    super.dispose();
  }
}
