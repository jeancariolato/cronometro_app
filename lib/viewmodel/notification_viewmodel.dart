

import 'package:cronometro/services/notification_services.dart';

class NotificationViewModel {
  final NotificationService _notificationService = NotificationService();

  Future<void> initializeNotifications() async {
    await _notificationService.initialize();
  }

  // Substitua o método antigo pelos novos métodos específicos
  Future<void> showRunningTimerNotification(String formattedTime) async {
    await _notificationService.showRunningTimerNotification(formattedTime);
  }

  Future<void> showLapNotification(int lapNumber, String lapTime, String totalTime) async {
    await _notificationService.showLapNotification(lapNumber, lapTime, totalTime);
  }

  Future<void> showInactivityNotification(String pausedTime) async {
    await _notificationService.showInactivityNotification(pausedTime);
  }

  Future<void> showResetNotification() async {
    await _notificationService.showResetNotification();
  }

  Future<void> cancelRunningTimerNotification() async {
    await _notificationService.cancelRunningTimerNotification();
  }

  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }
}