import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  GoogleMapController? _mapController;
  Set<Marker> _markers = <Marker>{};

  AppState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Station> get stations => _stations;
  Station? get selectedStation => _selectedStation;
  String? get selectedStationId => _selectedStation?.id;
  Set<Marker> get markers => _markers;

  CameraPosition get initialCameraPosition {
    final station =
        _selectedStation ?? (_stations.isNotEmpty ? _stations.first : null);

    if (station != null) {
      return CameraPosition(
        target: LatLng(station.latitude, station.longitude),
        zoom: 14,
      );
    }

    return const CameraPosition(target: LatLng(11.5564, 104.9282), zoom: 12);
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController?.dispose();
    _mapController = controller;
    _animateToSelectedOrFirstStation();
  }

  Future<void> initialize() async {
    _state = AppState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _stationsSubscription?.cancel();
      _stations = await _stationRepository.getAllStations();
      _syncMapState();
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
            } else {
              _selectedStation = null;
            }
          }

          _syncMapState();

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
      _syncMapState();
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

    _syncMapState();
    _animateToSelectedOrFirstStation();
    notifyListeners();
  }

  void _syncMapState() {
    _markers = _buildMarkers(onStationTap: selectStation);
  }

  Set<Marker> buildMarkers({required ValueChanged<String> onStationTap}) {
    return _buildMarkers(onStationTap: onStationTap);
  }

  Set<Marker> _buildMarkers({required ValueChanged<String> onStationTap}) {
    return _stations.map((station) {
      final isSelected = _selectedStation?.id == station.id;
      final hasAvailableBikes = station.hasAvailableBikes;

      final icon = isSelected
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
          : hasAvailableBikes
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);

      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude, station.longitude),
        icon: icon,
        alpha: isSelected
            ? 1
            : hasAvailableBikes
            ? 0.95
            : 0.65,
        zIndex: isSelected ? 2 : 1,
        infoWindow: InfoWindow(
          title: '${station.availableBikes} bikes',
          snippet: station.name,
        ),
        onTap: () => onStationTap(station.id),
      );
    }).toSet();
  }

  void _animateToSelectedOrFirstStation() {
    final station =
        _selectedStation ?? (_stations.isNotEmpty ? _stations.first : null);

    if (station == null || _mapController == null) {
      return;
    }

    unawaited(
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(station.latitude, station.longitude)),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _stationsSubscription?.cancel();
    super.dispose();
  }
}
