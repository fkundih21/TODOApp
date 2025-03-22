import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minimal_todo_app/screens/login_screen.dart';
import 'package:minimal_todo_app/services/auth_storage.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? token = await AuthStorage.getToken();

  // Notification initialization
  AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for task reminders',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        enableVibration: true,
      ),
    ],
  );

  runApp(MyApp(initialScreen: token != null ? HomeScreen() : LoginScreen()));}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  MyApp({required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: initialScreen,
    );
  }
}
