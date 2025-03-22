import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool?> showDeleteConfirmationDialog(BuildContext context, String name) {
  return showCupertinoDialog<bool>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            isDestructiveAction: true,
            child: Text('Yes'),
          ),
        ],
      );
    },
  );
}
