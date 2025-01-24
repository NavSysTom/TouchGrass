import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String text;

  const BioBox({
    super.key,
    required this.text,
    });

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.all(20.0),

      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(30.0),
      ),

      width: double.infinity,

      child: Text(text.isNotEmpty ? text : 'No bio available..', style: const TextStyle(  
        fontSize: 16.0,
        color: Colors.white,
      ),),
    );
  }
}