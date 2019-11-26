import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  String text;
  Function onPressed;
  Color buttonColor;
  double textFont;
  Color textColor;
  double height;
  bool showProgress;

  AppButton(
    this.text, {
    @required this.onPressed,
    this.buttonColor = Colors.grey,
    this.textFont = 22,
    this.textColor = Colors.black,
    this.height = 46,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: RaisedButton(
        color: buttonColor,
        child: showProgress
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: textFont,
                ),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
