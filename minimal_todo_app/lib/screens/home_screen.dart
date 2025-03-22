import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../utils/date_utils.dart';
import '../utils/notification_utils.dart';
import '../widgets/date_selection_header_widget.dart';
import '../widgets/task_item_widget.dart';
import '../widgets/task_progress_bar_widget.dart';
import 'add_task_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  DateTime selectedDate = DateTime.now();
  List<Task> tasks = [];
  String? token;

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    try {
      fetchTasks();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchTasks() async {
    try {
      token = await AuthStorage.getToken();
      List<Task> fetchedTasks = await apiService.fetchUserTasks(token!);
      setState(() {
        tasks = fetchedTasks;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to fetch tasks.");
      print(e);
    }
  }

  Future<void> deleteTask(int id) async {
    bool success = await apiService.deleteTask(id, token!);
    if (success) {
      setState(() {
        tasks.removeWhere((task) => task.id == id);
      });
      Fluttertoast.showToast(msg: "Task deleted.");
    } else {
      Fluttertoast.showToast(msg: "Failed to delete task.");
    }
  }

  Future<void> updateTaskCompletion(Task task, bool isCompleted) async {
    Task updatedTask = Task(
      id: task.id,
      name: task.name,
      time: task.time,
      isCompleted: isCompleted,
      hasReminder: task.hasReminder,
    );

    setState(() {
      task.isCompleted = isCompleted;
      print(updatedTask.isCompleted);
    });
    await apiService.updateTask(updatedTask, token!);
  }

  void logout() async {
    if (token != null) {
      await apiService.logoutUser(token!);
      await AuthStorage.removeToken();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dateList = generateDateList();

    List<Task> tasksForSelectedDate = tasks.where((task) {
      return task.time.year == selectedDate.year &&
          task.time.month == selectedDate.month &&
          task.time.day == selectedDate.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Mini',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: 'ToDo',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: logout,
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //DATE SELECTOR
          DateSelectorWidget(
            dateList: dateList,
            selectedDate: selectedDate,
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
              fetchTasks();
            },
          ),
          // TASK PROGRESS BAR
          TaskProgressBarWidget(
            tasks: tasks,
            selectedDate: selectedDate,
          ),
          // TASK LIST
          Expanded(
            child: tasksForSelectedDate.isEmpty
                ? Center(child: Text('No tasks for this day!'))
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: 75.0),
                    itemCount: tasksForSelectedDate.length,
                    itemBuilder: (context, index) {
                      var task = tasksForSelectedDate[index];
                      return TaskItem(
                        task: task,
                        onTaskCompletionChanged: updateTaskCompletion,
                        onDeleteTask: deleteTask,
                        onLongPressTask: (task) =>
                            handleTaskNotification(task, setState),
                      );
                    },
                  ),
          ),
        ],
      ),
      //NEW TASK BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? newTaskAdded = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (newTaskAdded == true) {
            fetchTasks();
          }
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.playlist_add_rounded, color: Colors.white, size: 40),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
