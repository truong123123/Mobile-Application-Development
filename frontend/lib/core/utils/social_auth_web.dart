import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

Future<String> authenticateWithPopup({
  required String url,
  required String callbackUrlScheme,
  int width = 500,
  int height = 700,
}) async {
  final completer = Completer<String>();
  Timer? timeoutTimer;
  StreamSubscription? msgSub;

  final left = (web.window.screen.width - width) ~/ 2;
  final top = (web.window.screen.height - height) ~/ 3;
  web.window.open(
      url, 'social_auth', 'width=$width,height=$height,left=$left,top=$top');

  debugPrint('[SocialAuth] Popup opened, waiting for postMessage...');
  debugPrint('[SocialAuth] Flutter origin: ${web.window.origin}');

  msgSub = web.window.onMessage.listen((web.MessageEvent event) {
    final eventOrigin = event.origin;
    debugPrint('[SocialAuth] Received message from origin: $eventOrigin');

    // Accept messages from same origin OR from Spring Boot (localhost:8080)
    // Flutter dev server runs on a different port than Spring Boot
    final isAllowedOrigin = eventOrigin == web.window.origin ||
        eventOrigin == 'http://localhost:8080' ||
        eventOrigin == 'https://localhost:8080';

    if (isAllowedOrigin) {
      final data = event.data;
      final map = data.dartify();
      debugPrint('[SocialAuth] Message data: $map');
      if (map is Map) {
        final authMsg = map['flutter-web-auth-2'];
        if (authMsg is String) {
          debugPrint('[SocialAuth] Got auth URL: $authMsg');
          timeoutTimer?.cancel();
          msgSub?.cancel();
          completer.complete(authMsg);
        }
      }
    } else {
      debugPrint(
          '[SocialAuth] Ignored message from disallowed origin: $eventOrigin');
    }
  });

  // Timeout sau 3 phút
  timeoutTimer = Timer(const Duration(minutes: 3), () {
    if (!completer.isCompleted) {
      msgSub?.cancel();
      completer.completeError(
        PlatformException(
          code: 'timeout',
          message: 'Timeout waiting for authentication',
        ),
      );
    }
  });

  return completer.future;
}
