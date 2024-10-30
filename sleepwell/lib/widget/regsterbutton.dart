import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  final Color color;
  final String title;
  final VoidCallback onPressed;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isLoading;

  const RegisterButton({
    Key? key,
    required this.color,
    required this.title,
    required this.onPressed,
    this.textColor = Colors.black,
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 5,
        color: color,
        borderRadius: BorderRadius.circular(10),
        child: MaterialButton(
          onPressed: isLoading ? null : onPressed,
          minWidth: 220,
          height: 42,
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                )
              : Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  ),
                ),
        ),
      ),
    );
  }
}
