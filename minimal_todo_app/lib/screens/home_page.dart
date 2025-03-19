import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/task_model.dart';
import '../services/api_service.dart';
import '../utils/date_utils.dart';
import '../utils/notification_utils.dart';
import '../widgets/delete_confirmation_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  DateTime selectedDate = DateTime.now();
  List<Task> tasks = [];
  String token = "...";

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      List<Task> fetchedTasks = await apiService.fetchTasks(token);
      setState(() {
        tasks = fetchedTasks;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed");
      print(e);
    }
  }

  Future<void> deleteTask(int id) async {
    bool success = await apiService.deleteTask(id, token);
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
    task.isCompleted = isCompleted;
    await apiService.updateTask(task, token);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dateList = generateDateList();

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
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildDatePicker(dateList),
          _buildTaskCounterWithProgress(),
          _buildTaskList(),
        ],
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? newTaskAdded = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddTaskPage(taskBox: tasks,)),
          );
          if (newTaskAdded == true) {
            fetchTasks();
          }
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.playlist_add_rounded, color: Colors.white, size: 40),
      ), */
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  // Datepicker
  Widget _buildDatePicker(List<DateTime> dateList) {
    return Container(
      height: 110,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dateList.map((date) {
            bool isSelected = date.day == selectedDate.day &&
                date.month == selectedDate.month &&
                date.year == selectedDate.year;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = date;
                });
              },
              child: AnimatedPadding(
                duration: Duration(milliseconds: 120),
                padding:
                    EdgeInsets.symmetric(horizontal: isSelected ? 15.0 : 9.0),
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    _buildDateCircle(date, isSelected),
                    _buildDayOfWeekText(date, isSelected),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Date list
  Widget _buildDateCircle(DateTime date, bool isSelected) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFC74709) : Colors.black26,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(
          duration: 200.ms,
          curve: Curves.easeInOut,
          begin: Offset(1.0, 1.0),
          end: Offset(1.175, 1.175),
        );
  }

  // Day text
  Widget _buildDayOfWeekText(DateTime date, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        getDayOfWeek(date),
        style: TextStyle(
          fontSize: isSelected ? 14 : 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Color(0xFFC74709) : Colors.black45,
        ),
      ).animate(target: isSelected ? 1 : 0).scale(
            duration: 350.ms,
            curve: Curves.easeInOut,
            begin: Offset(1.0, 1.0),
            end: Offset(1.175, 1.175),
          ),
    );
  }

  Widget _buildTaskCounterWithProgress() {
    var tasksForSelectedDate = tasks
        .where((task) =>
            task.time.day == selectedDate.day &&
            task.time.month == selectedDate.month &&
            task.time.year == selectedDate.year)
        .toList();

    int totalTasks = tasksForSelectedDate.length;
    int completedTasks =
        tasksForSelectedDate.where((task) => task.isCompleted).length;

    double progress = totalTasks > 0 ? completedTasks / totalTasks : 0;
    Color counterColor =
        completedTasks == totalTasks ? Color(0xFF0C5701) : Color(0xFF9A1313);

    if (totalTasks == 0) return SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          //Progress bar
          Expanded(
            flex: 8,
            child: LinearProgressIndicator(
              value: progress,
              color: Colors.orange,
              backgroundColor: Colors.grey.shade300,
              minHeight: 6,
            ),
          ),
          SizedBox(width: 10),
          // Task counter
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$completedTasks/$totalTasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: counterColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    var tasksForSelectedDate = tasks
        .where((task) =>
            task.time.day == selectedDate.day &&
            task.time.month == selectedDate.month &&
            task.time.year == selectedDate.year)
        .toList();

    if (tasksForSelectedDate.isEmpty) {
      return Expanded(child: Center(child: Text('No tasks for this day!')));
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 75.0),
        itemCount: tasksForSelectedDate.length,
        itemBuilder: (context, index) {
          var task = tasksForSelectedDate[index];
          return _buildTaskItem(task);
        },
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Dismissible(
      key: Key(task.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade900,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 35),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDeleteConfirmationDialog(context, task.name);
      },
      onDismissed: (direction) => deleteTask(task.id),
      child: Column(
        children: [
          ListTile(
            title: Text(
              task.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${task.time.hour}:${task.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: task.time.isBefore(DateTime.now()) && !task.isCompleted
                    ? Color(0xFF9A1313)
                    : Colors.black,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.hasReminder) Icon(Icons.notifications_active),
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    updateTaskCompletion(task, value ?? false);
                  },
                  activeColor: Colors.orange,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
            onLongPress: () => handleTaskNotification(task, setState),
          ),
          Divider(height: 1.5, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}
