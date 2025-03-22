import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

final AwesomeNotifications _notifications = AwesomeNotifications();

void requestNotificationPermission() async {
  bool isAllowed = await _notifications.isNotificationAllowed();
  if (!isAllowed) {
    _notifications.requestPermissionToSendNotifications();
  }
}

void handleTaskNotification(
    Task task, void Function(VoidCallback fn) updateState) async {
  String? token = await AuthStorage.getToken();
  if (token == null) return;

  ApiService apiService = ApiService();

  if (!task.hasReminder) {
    updateState(() {
      task.hasReminder = true;
    });

    await apiService.updateTask(task, token!);

    Fluttertoast.showToast(msg: "Notification for ${task.name} was created");

    DateTime utcTime = task.time.toUtc();

    await _notifications.createNotification(
      content: NotificationContent(
        id: task.id,
        channelKey: 'basic_channel',
        title: 'Reminder for ${task.name}',
        body: ' ⌛ Your task is due now!',
        category: NotificationCategory.Reminder,
        largeIcon: 'resource://mipmap-mdpi/ic_launcher',
        notificationLayout: NotificationLayout.BigText,
        displayOnForeground: true,
        displayOnBackground: true,
      ),
      schedule: NotificationCalendar(
        year: utcTime.year,
        month: utcTime.month,
        day: utcTime.day,
        hour: utcTime.hour,
        minute: utcTime.minute,
        second: 0,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  } else {
    AwesomeNotifications().cancel(task.id);
    Fluttertoast.showToast(msg: "Notification for ${task.name} was canceled");

    updateState(() {
      task.hasReminder = false;
    });

    await apiService.updateTask(task, token);
  }
}
