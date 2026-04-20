// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

const String _scriptId = 'google-maps-js-sdk';

Future<void> ensureGoogleMapsJsLoadedImpl({required String apiKey}) async {
  if (apiKey.isEmpty) {
    debugPrint(
      'GOOGLE_MAPS_API_KEY is empty. Google Maps web SDK will not be loaded.',
    );
    return;
  }

  if (html.document.getElementById(_scriptId) != null) {
    return;
  }

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..id = _scriptId
    ..type = 'text/javascript'
    ..async = true
    ..defer = true
    ..src =
      'https://maps.googleapis.com/maps/api/js?key=${Uri.encodeQueryComponent(apiKey)}&loading=async';

  script.onLoad.first.then((_) {
    if (!completer.isCompleted) {
      completer.complete();
    }
  });

  script.onError.first.then((_) {
    if (!completer.isCompleted) {
      completer.completeError(
        StateError('Failed to load Google Maps JavaScript SDK.'),
      );
    }
  });

  html.document.head?.append(script);

  try {
    await completer.future.timeout(const Duration(seconds: 20));
  } catch (error) {
    debugPrint('Google Maps web SDK load failed: $error');
  }
}
