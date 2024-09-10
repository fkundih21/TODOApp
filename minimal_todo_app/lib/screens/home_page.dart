import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task.dart';
import 'add_task_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

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
    _requestNotificationPermission();
  }

  void _requestNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // List of dates
  List<DateTime> _generateDateList() {
    return List.generate(7, (index) => DateTime.now().subtract(Duration(days: 3 - index)));
  }

  // Labele za dane
  String _getDayOfWeek(DateTime date) {
    if (_isToday(date)) return 'Today';
    if (_isYesterday(date)) return 'Yesterday';
    if (_isTomorrow(date)) return 'Tomorrow';
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, String taskName) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete "$taskName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dateList = _generateDateList();

    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo App'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_sharp),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Scrollable date picker
            Container(
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
                        padding: EdgeInsets.symmetric(horizontal: isSelected ? 15.0 : 9.0),
                        child: Column(
                          children: [
                            SizedBox(height: 8),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.grey.shade700 : Colors.black26,
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
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                _getDayOfWeek(date),
                                style: TextStyle(
                                  fontSize: isSelected ? 14 : 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.black54 : Colors.black45,
                                ),
                              ).animate(target: isSelected ? 1 : 0).scale(
                                duration: 350.ms,
                                curve: Curves.easeInOut,
                                begin: Offset(1.0, 1.0),
                                end: Offset(1.175, 1.175),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Task list
            Expanded(
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
                    itemCount: tasksForSelectedDate.length,
                    itemBuilder: (context, index) {
                      var task = tasksForSelectedDate[index];

                      return Dismissible(
                        key: Key(task.key.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmationDialog(context, task.name);
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
                        child: ListTile(
                          title: Text(task.name),
                          subtitle: Text(
                            '${task.time.hour}:${task.time.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: task.time.isBefore(DateTime.now()) && !task.isCompleted
                                  ? Colors.red.shade900
                                  : Colors.black,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (task.hasNotification)
                                Icon(Icons.notifications_active),
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (bool? value) {
                                  setState(() {
                                    task.isCompleted = value ?? false;
                                    task.save();
                                  });
                                },
                              ),
                            ],
                          ),
                          onLongPress: () {
                            if (!task.hasNotification) {
                              setState(() {
                                task.hasNotification = true;
                                task.save();
                              });
                              Fluttertoast.showToast(
                                  msg: "Notification for ${task.name} was created");
                              AwesomeNotifications().createNotification(
                                content: NotificationContent(
                                  id: task.key,
                                  channelKey: 'basic_channel',
                                  title: 'Reminder for ${task.name}',
                                  body: 'Your task is due now!',
                                  category: NotificationCategory.Reminder,
                                  largeIcon: 'resource://mipmap-mdpi/ic_launcher',
                                  notificationLayout: NotificationLayout.BigText,
                                  displayOnForeground: true,
                                  displayOnBackground: true,
                                ),
                                schedule: NotificationCalendar.fromDate(
                                  date: task.time,
                                ),
                              );
                            } else {
                              AwesomeNotifications().cancel(task.key);
                              Fluttertoast.showToast(
                                  msg: "Notification for ${task.name} was canceled");
                              setState(() {
                                task.hasNotification = false;
                                task.save();
                              });
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Add tasks button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTaskPage(taskBox: taskBox),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
