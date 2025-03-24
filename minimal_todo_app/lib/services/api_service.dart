import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task_model.dart';

class ApiService {
  static const String baseUrl = "https://aa7a-2a00-c30-71ea-bcb0-7018-6dfc-7e7-103.ngrok-free.app/api";

  // GET All tasks
  Future<List<Task>> fetchTasks(String token) async {
    final url = Uri.parse('$baseUrl/tasks');
    final response = await http.get(url, headers: _getHeadersWithToken(token));

    if (response.statusCode == 200) {
      List<dynamic> tasksJson = jsonDecode(response.body);
      List<Task> tasks = tasksJson.map((item) => Task.fromJson(item)).toList();
      return tasks;
    } else {
      throw Exception(
          'Failed to load tasks. Status code: ${response.statusCode}');
    }
  }

  // POST New task
  Future<Task> addTask(Task task, String token) async {
    final url = Uri.parse('$baseUrl/tasks');
    final response = await http.post(url,
        headers: _getHeadersWithToken(token),
        body: jsonEncode(task.toJson()));

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to add task. Status code: ${response.statusCode}');
    }
  }

  // PUT Update existing task
  Future<Task> updateTask(Task task, String token) async {
    final url = Uri.parse('$baseUrl/tasks/${task.id}');
    final response = await http.put(url,
        headers: _getHeadersWithToken(token),
        body: jsonEncode(task.toJson()));

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to update task. Status code: ${response.statusCode}');
    }
  }

  //DELETE Existing task
  Future<bool> deleteTask(int id, String token) async {
    final url = Uri.parse('$baseUrl/tasks/$id');
    final response = await http.delete(url, headers: _getHeadersWithToken(token));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Failed to delete task. Status code: ${response.statusCode}');
    }
  }

  //POST Register new user
  Future<Map<String, dynamic>?> registerUser(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to register user. Status code: ${response.statusCode}');
    }
  }

  // POST Login user
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to login user. Status code: ${response.statusCode}');
    }
  }

  // POST Logout user
  Future<bool> logoutUser(String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/logout"),
      headers: _getHeadersWithToken(token),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to logout. Status code: ${response.statusCode}');
    }
  }

  // GET All user tasks
  Future<List<Task>> fetchUserTasks(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: _getHeadersWithToken(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> taskJson = jsonDecode(response.body);
      return taskJson.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user tasks');
    }
  }

  /// HEADER WITH TOKEN SHORTCUT
  Map<String, String> _getHeadersWithToken(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

}
