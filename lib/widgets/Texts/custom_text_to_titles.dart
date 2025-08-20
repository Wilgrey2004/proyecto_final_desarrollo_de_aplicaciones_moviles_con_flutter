import 'package:flutter/material.dart';

class CustomTextToTitles extends StatelessWidget {
  final String title;
  const CustomTextToTitles({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
