import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/task.dart';

void requestNotificationPermission() async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
}
void handleTaskNotification(Task task, void Function(VoidCallback fn) updateState) {
  if (!task.hasNotification) {
    updateState(() {
      task.hasNotification = true;
      task.save();
    });
    Fluttertoast.showToast(msg: "Notification for ${task.name} was created");
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: task.key,
        channelKey: 'basic_channel',
        title: 'Reminder for ${task.name}',
        body: 'Your task is due now!',
        category: NotificationCategory.Reminder,
        largeIcon: 'resource://mipmap-mdpi/ic_launcher',
        notificationLayout: NotificationLayout.BigText,
        displayOnForeground: true,
        displayOnBackground: true,
      ),
      schedule: NotificationCalendar.fromDate(date: task.time, allowWhileIdle: true),
    );
  } else {
    AwesomeNotifications().cancel(task.key);
    Fluttertoast.showToast(msg: "Notification for ${task.name} was canceled");
    updateState(() {
      task.hasNotification = false;
      task.save();
    });
  }
}
