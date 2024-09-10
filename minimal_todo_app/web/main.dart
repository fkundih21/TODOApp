import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:minimal_todo_app/main.dart'; // Zamijenite 'your_app_name' sa stvarnim nazivom vašeg paketa

void main() {
  setUrlStrategy(PathUrlStrategy()); // Omogućava bolje rukovanje URL-ovima na webu
  runApp(MyApp());
}