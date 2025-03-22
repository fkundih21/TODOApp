import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../widgets/delete_confirmation_dialog.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(Task, bool) onTaskCompletionChanged;
  final Function(int) onDeleteTask;
  final Function(Task) onLongPressTask;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onTaskCompletionChanged,
    required this.onDeleteTask,
    required this.onLongPressTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      onDismissed: (direction) => onDeleteTask(task.id),
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
                color: task.time.toLocal().isBefore(DateTime.now()) && !task.isCompleted
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
                    onTaskCompletionChanged(task, value ?? false);
                  },
                  activeColor: Colors.orange,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
            onLongPress: () => onLongPressTask(task),
          ),
          Divider(height: 1.5, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}
