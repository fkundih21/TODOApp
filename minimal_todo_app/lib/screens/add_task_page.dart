import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/time_picker_widget.dart';

class AddTaskPage extends StatefulWidget {
  final Box<Task> taskBox;

  AddTaskPage({required this.taskBox});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _taskController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();

  // Save task
  void _saveTask() {
    if (_taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a task name')),
      );
      return;
    }

    final newTask = Task(
      name: _taskController.text,
      time: selectedDateTime, id: 1, isCompleted: false, hasReminder: false,
    );

    widget.taskBox.add(newTask);

    Fluttertoast.showToast(
      msg: 'Task "${newTask.name}" was added"',
    );
    Navigator.of(context).pop();
  }

  // Datepicker
  void _selectDate() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DatePickerWidget(
          initialDate: selectedDateTime,
          onDateChanged: (newDate) {
            setState(() {
              selectedDateTime = DateTime(
                newDate.year,
                newDate.month,
                newDate.day,
                selectedDateTime.hour,
                selectedDateTime.minute,
              );
            });
          },
        );
      },
    );
  }

  // Timepicker
  void _selectTime() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return TimePickerWidget(
          initialTime: selectedDateTime,
          onTimeChanged: (newTime) {
            setState(() {
              selectedDateTime = newTime;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),

              // Date Picker
              Row(
                children: [
                  Text('Date: ', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          dateFormat.format(selectedDateTime),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectDate,
                    icon: Icon(Icons.calendar_today),
                    iconSize: 24,
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Time Picker
              Row(
                children: [
                  Text('Time: ', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          timeFormat.format(selectedDateTime),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectTime,
                    icon: Icon(Icons.access_time),
                    iconSize: 24,
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
