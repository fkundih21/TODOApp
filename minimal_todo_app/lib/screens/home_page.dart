import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';
import '../utils/date_utils.dart';
import '../utils/notification_utils.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<Task> taskBox;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('tasksBox');
    requestNotificationPermission();
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
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDatePicker(dateList),
            _buildTaskCounterWithProgress(),
            _buildTaskList(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15, right: 15),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddTaskPage(taskBox: taskBox),
              ),
            );
          },
          backgroundColor: Colors.orange,
          child:
              Icon(Icons.playlist_add_rounded, color: Colors.white, size: 40),
        ),
      ),
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

  // Task counter with progress bar
  Widget _buildTaskCounterWithProgress() {
    return ValueListenableBuilder(
      valueListenable: taskBox.listenable(),
      builder: (context, Box<Task> box, _) {
        var tasksForSelectedDate = box.values.where((task) {
          return task.time.day == selectedDate.day &&
              task.time.month == selectedDate.month &&
              task.time.year == selectedDate.year;
        }).toList();

        int totalTasks = tasksForSelectedDate.length;
        int completedTasks =
            tasksForSelectedDate.where((task) => task.isCompleted).length;

        double progress = totalTasks > 0 ? completedTasks / totalTasks : 0;
        Color counterColor = completedTasks == totalTasks
            ? Color(0xFF0C5701)
            : Color(0xFF9A1313);

        if (totalTasks == 0) return SizedBox();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              // Progress bar
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
      },
    );
  }

  // Task list
  Widget _buildTaskList() {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box<Task> box, _) {
          var tasksForSelectedDate = box.values.where((task) {
            return task.time.day == selectedDate.day &&
                task.time.month == selectedDate.month &&
                task.time.year == selectedDate.year;
          }).toList();

          if (tasksForSelectedDate.isEmpty) {
            return Center(child: Text('No tasks for this day!'));
          }

          return ListView.builder(
            padding: EdgeInsets.only(bottom: 75.0),
            itemCount: tasksForSelectedDate.length,
            itemBuilder: (context, index) {
              var task = tasksForSelectedDate[index];
              return _buildTaskItem(task);
            },
          );
        },
      ),
    );
  }

  // Task item
  Widget _buildTaskItem(Task task) {
    return Dismissible(
      key: Key(task.key.toString()),
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
      onDismissed: (direction) {
        taskBox.delete(task.key);
        Fluttertoast.showToast(
          msg: "Task '${task.name}' was deleted",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
      },
      child: Column(
        children: [
          ListTile(
            title: Text(
              task.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
                if (task.hasNotification) Icon(Icons.notifications_active),
                Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Colors.grey,
                  ),
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      setState(() {
                        task.isCompleted = value ?? false;
                        task.save();
                      });
                    },
                    activeColor: Colors.orange,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
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
