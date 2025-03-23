import 'package:flutter/material.dart';

Widget TextFieldInput(TextEditingController controller, String label,
    {bool isPassword = false}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}