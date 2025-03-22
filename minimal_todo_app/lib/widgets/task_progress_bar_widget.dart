import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskProgressBarWidget extends StatelessWidget {
  final List<Task> tasks;
  final DateTime selectedDate;

  const TaskProgressBarWidget({
    Key? key,
    required this.tasks,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tasksForSelectedDate = tasks.where((task) {
      return task.time.year == selectedDate.year &&
          task.time.month == selectedDate.month &&
          task.time.day == selectedDate.day;
    }).toList();

    int totalTasks = tasksForSelectedDate.length;
    int completedTasks = tasksForSelectedDate.where((task) => task.isCompleted).length;

    double progress = totalTasks > 0 ? completedTasks / totalTasks : 0;
    Color counterColor = completedTasks == totalTasks ? Color(0xFF0C5701) : Color(0xFF9A1313);

    if (totalTasks == 0) return SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
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
}
