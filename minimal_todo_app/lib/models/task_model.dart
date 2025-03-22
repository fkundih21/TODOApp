class Task {
  int id;
  String name;
  DateTime time;
  bool isCompleted;
  bool hasReminder;

  Task({
    required this.id,
    required this.name,
    required this.time,
    required this.isCompleted,
    required this.hasReminder,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      time: DateTime.parse(json['time']),
      isCompleted: json['is_completed'],
      hasReminder: json['has_reminder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time': time.toIso8601String(),
      'is_completed': isCompleted,
      'has_reminder': hasReminder,
    };
  }
}
