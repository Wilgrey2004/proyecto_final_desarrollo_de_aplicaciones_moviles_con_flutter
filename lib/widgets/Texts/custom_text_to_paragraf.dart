import 'package:flutter/material.dart';

class CustomTextToParagraf extends StatelessWidget {
  final String Texto;

  const CustomTextToParagraf({super.key, required this.Texto});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "$Texto",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
    );
  }
}
