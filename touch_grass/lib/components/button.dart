import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
  });

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.all(10.0), // Add margin
      decoration: BoxDecoration(
        color: Colors.grey, // Corrected color spelling
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Make text bold
          ),
        ),
      ),
    ),
  );
  }
}