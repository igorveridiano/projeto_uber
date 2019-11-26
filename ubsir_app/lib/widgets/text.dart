import 'package:flutter/material.dart';

Text text(
  String text, {
  double fontSize = 16,
  color = Colors.black,
  bold = false,
}) {
  return Text(
    text ?? "",
    style: TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}
