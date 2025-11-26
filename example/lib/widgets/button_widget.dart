import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String buttonText;
  final Function callBack;
  final Color? backgroundColor;
  const ButtonWidget({
    super.key,
    required this.buttonText,
    required this.callBack,
    this.backgroundColor = Colors.blue
  });


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        callBack.call();
      },
      child: Text(buttonText),
    );
  }
}
