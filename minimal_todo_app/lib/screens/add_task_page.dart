import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

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
    if (_taskController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a task name')),
      );
      return;
    }

    final newTask = Task(
      name: _taskController.text,
      time: selectedDateTime,
      isCompleted: false,
    );

    widget.taskBox.add(newTask);
    Navigator.of(context).pop();
  }

  // Datepicker
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        );
      });
    }
  }

  // Timepicker
  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (pickedTime != null) {
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Task'),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                  textStyle: TextStyle(fontSize: 18),
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
