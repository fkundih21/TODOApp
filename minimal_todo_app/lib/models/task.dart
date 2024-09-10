import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late DateTime time;

  @HiveField(2)
  late bool isCompleted;

  @HiveField(3)
  late bool hasNotification;

  Task({required this.name, required this.time, this.isCompleted = false, this.hasNotification = false});
}
