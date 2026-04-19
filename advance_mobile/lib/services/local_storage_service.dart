import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for handling local persistence and caching.
/// Uses SharedPreferences to store simple data and JSON-encoded objects.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  // Keys
  static const String _userPrefsKey = 'user_preferences';
  static const String _stationsCacheKey = 'stations_cache';
  static const String _lastSyncKey = 'last_sync_timestamp';

  /// Save a simple string value
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Get a simple string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save a boolean value
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Remove a specific key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Clear all local storage
  Future<void> clear() async {
    await _prefs.clear();
  }

  /// Save a JSON object/map
  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    await _prefs.setString(key, jsonEncode(json));
  }

  /// Get a JSON object/map
  Map<String, dynamic>? getJson(String key) {
    final data = _prefs.getString(key);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Save a list of JSON objects
  Future<void> saveJsonList(String key, List<Map<String, dynamic>> list) async {
    await _prefs.setString(key, jsonEncode(list));
  }

  /// Get a list of JSON objects
  List<Map<String, dynamic>>? getJsonList(String key) {
    final data = _prefs.getString(key);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return null;
    }
  }

  /// Helper to get last sync time
  DateTime? getLastSyncTime() {
    final timestamp = _prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Helper to update last sync time
  Future<void> updateLastSyncTime() async {
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }
}
