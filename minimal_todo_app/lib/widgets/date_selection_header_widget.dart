import 'package:flutter/material.dart';

import '../utils/date_utils.dart';

class DateSelectorWidget extends StatelessWidget {
  final List<DateTime> dateList;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateSelectorWidget({
    Key? key,
    required this.dateList,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onTap: () => onDateSelected(date),
              child: AnimatedPadding(
                duration: Duration(milliseconds: 120),
                padding:
                    EdgeInsets.symmetric(horizontal: isSelected ? 15.0 : 9.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildDateCircle(date, isSelected),
                    _buildDayOfWeekText(date, isSelected),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateCircle(DateTime date, bool isSelected) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFC74709) : Colors.black26,
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
    );
  }

  Widget _buildDayOfWeekText(DateTime date, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        getDayOfWeek(date),
        style: TextStyle(
          fontSize: isSelected ? 14 : 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Color(0xFFC74709) : Colors.black45,
        ),
      ),
    );
  }
}
