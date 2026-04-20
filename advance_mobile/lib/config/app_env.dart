import 'package:flutter/services.dart';

/// Runtime environment values loaded from local .env asset.
class AppEnv {
  static const String _compileTimeGoogleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  static bool _isLoaded = false;
  static final Map<String, String> _values = <String, String>{};

  static Future<void> load() async {
    if (_isLoaded) {
      return;
    }

    try {
      final raw = await rootBundle.loadString('.env');
      _values.addAll(_parse(raw));
    } catch (_) {
      // Keep empty values when .env is absent.
    }

    _isLoaded = true;
  }

  static String get googleMapsApiKey {
    if (_compileTimeGoogleMapsApiKey.isNotEmpty) {
      return _compileTimeGoogleMapsApiKey;
    }

    return (_values['GOOGLE_MAPS_API_KEY'] ?? '').trim();
  }

  static Map<String, String> _parse(String raw) {
    final result = <String, String>{};

    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final separatorIndex = trimmed.indexOf('=');
      if (separatorIndex <= 0) {
        continue;
      }

      final key = trimmed.substring(0, separatorIndex).trim();
      var value = trimmed.substring(separatorIndex + 1).trim();

      if (value.length >= 2 &&
          ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'")))) {
        value = value.substring(1, value.length - 1);
      }

      result[key] = value;
    }

    return result;
  }
}
