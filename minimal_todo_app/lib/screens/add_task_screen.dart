import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/time_picker_widget.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();
  final ApiService _apiService = ApiService();
  bool isLoading = false;

  Future<void> _saveTask() async {
    if (_taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a task name')),
      );
      return;
    }

    setState(() => isLoading = true);

    String? token = await AuthStorage.getToken();
    if (token == null) {
      Fluttertoast.showToast(msg: 'User is not authenticated.');
      setState(() => isLoading = false);
      return;
    }

    Task newTask = Task(
      id: 0,
      name: _taskController.text,
      time: selectedDateTime,
      isCompleted: false,
      hasReminder: false,
    );

    try {
      await _apiService.addTask(newTask, token);
      Fluttertoast.showToast(msg: 'Task added successfully!');
      Navigator.of(context).pop(true);
    } catch (error) {
      Fluttertoast.showToast(msg: 'Error: ${error.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

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
      appBar: AppBar(title: Text('New Task')),
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
                  ),
                ],
              ),
              SizedBox(height: 16),
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
                  ),
                ],
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
