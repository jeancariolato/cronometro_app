import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // IDs para diferentes tipos de notificações
  static const int _runningTimerNotificationId = 1;
  static const int _lapNotificationIdStart =
      100; // IDs de 100 em diante para voltas
  static const int _inactivityNotificationId = 2;
  static const int _resetNotificationId = 3;

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted =
          await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // 1. Notificação de cronômetro em execução (persistente)
  Future<void> showRunningTimerNotification(String formattedTime) async {
    if (!await _requestPermissions()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'running_timer_channel',
      'Cronômetro em Execução',
      channelDescription:
          'Notificação persistente quando o cronômetro está em execução',
      importance:
          Importance.low, // Menor importância para notificação persistente
      priority: Priority.low,
      ongoing: true, // Torna a notificação persistente
      autoCancel: false, // Impede o cancelamento automático
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      _runningTimerNotificationId,
      'Cronômetro em Execução',
      'Tempo atual: $formattedTime',
      platformChannelSpecifics,
    );
  }

  // 2. Notificação de volta registrada
  Future<void> showLapNotification(
      int lapNumber, String lapTime, String totalTime) async {
    if (!await _requestPermissions()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'lap_notification_channel',
      'Voltas Registradas',
      channelDescription: 'Notificações para cada volta registrada',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      _lapNotificationIdStart + lapNumber, // ID único para cada volta
      'Volta $lapNumber Registrada',
      'Tempo da volta: $lapTime\nTempo total: $totalTime',
      platformChannelSpecifics,
    );
  }

  // 3. Notificação de inatividade (quando o cronômetro fica pausado por mais de 10 segundos)
  Future<void> showInactivityNotification(String pausedTime) async {
    if (!await _requestPermissions()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'inactivity_notification_channel',
      'Lembrete de Inatividade',
      channelDescription:
          'Notificações quando o cronômetro fica pausado por muito tempo',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      _inactivityNotificationId,
      'Cronômetro Pausado',
      'Seu cronômetro está pausado há mais de 10 segundos.\nTempo atual: $pausedTime',
      platformChannelSpecifics,
    );
  }

  // 4. Notificação de reinicialização do cronômetro
  Future<void> showResetNotification() async {
    if (!await _requestPermissions()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reset_notification_channel',
      'Reinicialização',
      channelDescription: 'Notificação quando o cronômetro é reiniciado',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      _resetNotificationId,
      'Cronômetro Reiniciado',
      'O cronômetro foi reiniciado com sucesso.',
      platformChannelSpecifics,
    );
  }

  // Método para cancelar a notificação persistente do cronômetro
  Future<void> cancelRunningTimerNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(_runningTimerNotificationId);
  }

  // Método para cancelar todas as notificações
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
