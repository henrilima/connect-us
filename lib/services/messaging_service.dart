import 'package:connect/services/database_service.dart';
import 'package:connect/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  final NotificationService _notifier = NotificationService();

  Future<void> init(String userId) async {
    await _notifier.initNotification();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permissão concedida');
    }

    String? token = await messaging.getToken();
    if (token != null) {
      await DatabaseService().setUserMessagerToken(userId, token);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Recebi uma mensagem em primeiro plano: ${message.notification?.title}:${message.notification?.body}',
      );
      if (message.notification != null) {
        _notifier.showNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
      }
    });
  }

  Future<void> requestPermission() async {
    await _notifier.requestNotificationPermission();
  }
}
