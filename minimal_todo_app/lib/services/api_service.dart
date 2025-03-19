import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/task_model.dart';

class ApiService {
  static const String baseUrl = "http://...:8000/api";

  // GET All tasks
  Future<List<Task>> fetchTasks(String token) async {
    final url = Uri.parse('$baseUrl/tasks');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List<dynamic> tasksJson = jsonDecode(response.body);
      List<Task> tasks = tasksJson.map((item) => Task.fromJson(item)).toList();
      return tasks;
    } else {
      throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
    }
  }

  // POST New task
  Future<Task> addTask(Task task, String token) async {
    final url = Uri.parse('$baseUrl/tasks');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toJson()));

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add task. Status code: ${response.statusCode}');
    }
  }

  // PUT Update existing task
  Future<Task> updateTask(Task task, String token) async {
    final url = Uri.parse('$baseUrl/tasks/${task.id}');
    final response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toJson()));

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update task. Status code: ${response.statusCode}');
    }
  }

  //DELETE existing task
  Future<bool> deleteTask(int id, String token) async {
    final url = Uri.parse('$baseUrl/tasks/$id');
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete task. Status code: ${response.statusCode}');
    }
  }
}