import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(
            top: 20.0, left: 20.0, bottom: 16.0, right: 10.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
