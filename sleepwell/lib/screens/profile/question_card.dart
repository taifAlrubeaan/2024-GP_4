// question_card.dart
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final List<String> options;
  final String answer;
  final ValueChanged<String> onChanged;
  final String feedback;

  const QuestionCard({
    required this.question,
    required this.options,
    required this.answer,
    required this.onChanged,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Text(
              question,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Dropdown for answer selection
            DropdownButton<String>(
              value: answer.isNotEmpty && options.contains(answer)
                  ? answer
                  : null, // Handle if value is missing
              isExpanded: true, // Allow the dropdown to take full width
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10), // White text
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              dropdownColor: Color.fromARGB(
                  255, 60, 60, 154), // Optional: Dropdown background color
              iconEnabledColor: Colors.white, // Dropdown icon color
            ),
            const SizedBox(height: 20),

            // Scrollable feedback section
            SingleChildScrollView(
              child: Text(
                feedback,
                style: TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                softWrap: true, // Wrap text to the next line if needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
