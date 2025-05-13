import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String message;

  const ErrorText(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(color: Colors.red, fontSize: 18),
      textAlign: TextAlign.center,
    );
  }
}
