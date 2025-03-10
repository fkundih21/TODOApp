import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimePickerWidget extends StatelessWidget {
  final DateTime initialTime;
  final ValueChanged<DateTime> onTimeChanged;

  const TimePickerWidget({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Select Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: Duration(
                hours: initialTime.hour,
                minutes: initialTime.minute,
              ),
              onTimerDurationChanged: (Duration newTime) {
                final updatedTime = DateTime(
                  initialTime.year,
                  initialTime.month,
                  initialTime.day,
                  newTime.inHours,
                  newTime.inMinutes % 60,
                  0,
                );
                onTimeChanged(updatedTime);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
}
