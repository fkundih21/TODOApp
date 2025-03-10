import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const DatePickerWidget({
    Key? key,
    required this.initialDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              initialDateTime: initialDate,
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: onDateChanged,
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
