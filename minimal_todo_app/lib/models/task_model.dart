class Task {
  final int id;
  final String name;
  final DateTime time;
  late final bool isCompleted;
  late final bool hasReminder;

  Task({
    required this.id,
    required this.name,
    required this.time,
    required this.isCompleted,
    required this.hasReminder,
  });

  // JSON to Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        id: json['id'],
        name: json['name'],
        time: DateTime.parse(json['time']),
        isCompleted: json['is_completed'],
        hasReminder: json['has_reminder']
    );
  }

  //Task object to JSON
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
