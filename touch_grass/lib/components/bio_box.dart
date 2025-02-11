import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String text;

  const BioBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBioEmpty = text.isEmpty;

    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[300], // Light grey color
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: double.infinity,
      child: Text(
        isBioEmpty ? 'No bio available..' : text,
        style: TextStyle(
          fontSize: 16.0,
          color: isBioEmpty ? Colors.grey : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}