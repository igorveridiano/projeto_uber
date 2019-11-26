import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  String label;
  String hint;
  TextEditingController controller;
  double textFont;
  Color textColor;
  double labelFont;
  Color labelColor;
  double hintFont;
  Color hintColor;
  bool obscureText;
  FormFieldValidator<String> validator;
  TextInputType keyboardType;
  Brightness keyboardAppearance;
  TextInputAction textInputAction;
  FocusNode focusNode;
  FocusNode nextFocus;
  bool autofocus;

  AppText(
    this.label,
    this.hint, {
    this.controller,
    this.textFont = 25,
    this.textColor = Colors.black54,
    this.labelFont = 25,
    this.labelColor = Colors.black54,
    this.hintFont = 16,
    this.hintColor = Colors.black54,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.keyboardAppearance = Brightness.dark,
    this.textInputAction,
    this.focusNode,
    this.nextFocus,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      keyboardAppearance: keyboardAppearance,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: (String text) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      style: TextStyle(
        fontSize: textFont,
        color: textColor,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        labelStyle: TextStyle(
          fontSize: labelFont,
          color: labelColor,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: hintFont,
          color: hintColor,
        ),
      ),
    );
  }
}
