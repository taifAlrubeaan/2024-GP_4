import 'package:flutter/material.dart';

class QuestionCard extends StatefulWidget {
  final String question;
  final List<String> options;
  final String answer;
  final ValueChanged<String> onChanged;

  const QuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.answer,
    required this.onChanged,
  });

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _selectedAnswer = widget.options.contains(widget.answer)
        ? widget.answer
        : null; // تعيينها إلى null إذا كانت الإجابة ليست ضمن الخيارات
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.black),
      ),
      child: Container(
        color: const Color.fromARGB(255, 207, 203, 252),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.question,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
              DropdownButton<String>(
                value: widget.options.contains(_selectedAnswer)
                    ? _selectedAnswer
                    : null, // التأكد من أن القيمة موجودة ضمن الخيارات
                isExpanded: true,
                hint: const Text(
                  'Select an answer',
                  style: TextStyle(color: Colors.white),
                ),
                items: widget.options.map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAnswer = newValue;
                    widget.onChanged(_selectedAnswer!);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
