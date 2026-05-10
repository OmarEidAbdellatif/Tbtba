import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_riverpod.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  WidgetRef? _ref;

  void initialize(WidgetRef ref) {
    _ref = ref;
    // In a real app, this is where you'd setup FirebaseMessaging listeners:
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    // FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
  }

  // Simulated method to trigger a notification action
  void simulateIncomingNotification(String type) {
    if (_ref != null) {
      final provider = _ref!.read(appRiverpod);
      provider.handleDeepLink(type);
    }
  }

  // Real-world example of how it would look with Firebase
  /*
  void _handleMessage(RemoteMessage message) {
    final type = message.data['type'];
    if (type != null && _ref != null) {
      _ref!.read(appRiverpod).handleDeepLink(type);
    }
  }
  */
}

final notificationServiceProvider = Provider((ref) => NotificationService());
