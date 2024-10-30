import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/screens/auth/signin_screen.dart';
import 'package:sleepwell/screens/home_screen.dart';

class QuestionScreen extends StatefulWidget {
  static String RouteScreen = 'question';
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();

  // @override
  //_QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  late String userId;
  late String email;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      setState(() {
        showSpinner = true; // Show spinner while fetching user
      });

      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          userId = user.uid;
          email = user.email!;
        });
      }

      setState(() {
        showSpinner = false; // Hide spinner after fetching user
      });
    } catch (e) {
      print(e);
      setState(() {
        showSpinner = false; // Hide spinner in case of an error
      });
    }
  }

  int currentQuestionIndex = 0;
  List<String> questions = [
    'Q1:How consistent is your sleep schedule?',
    'Q2:Do you have a regular bedtime routine? ',
    'Q3:How often do you wake up tired in the morning?',
    'Q4:How much sleep do you usually get at night?',
    'Q5:How long does it take to fall asleep after you get into bed?',
    'Q6: Do you use your smartphone within 30 minutes before bedtime?',
    'Q7:Do you consume caffeine close to bedtime?',
    'Q8:When do you typically stop consuming coffee, tea, smoking, and other substances before bedtime?',
    'Q9:What activities do you typically engage in during the two hours leading up to your bedtime?',
    'Q10:Do you frequently consume food or snacks during the night?',
    //'Question 8',
  ];

  List<List<String>> options = [
    ['Very consistent', 'Somewhat consistent', 'Inconsistent'], //q1
    ['Yes', 'Occasionally', 'No'], //q2
    ['Always', 'Usually', 'Sometimes', 'Rarely'], //q3
    ['6 hours or less', '6-8 hours', '8-10hours', '10 hours or more'], //q4
    [
      'everal minutes',
      '10-15 minutes',
      '20-40 minutes',
      'Hard to fall asleep'
    ], //q5
    ['Yes', 'Occasionally', 'No'],
    ['Yes', 'Occasionally', 'No'],
    [
      'I stop consuming at least 1-2 hours before bedtime',
      'I stop consuming at least 3-4 hours before bedtime',
      'I do not consume these substances at all',
      'I use these substances right before bedtime'
    ],
    [
      'Engage in relaxation techniques',
      'Engage in physical activity or exercise',
      ' Engage in activities that may increase stress ',
      'Other'
    ],
    ['Yes', 'Occasionally', 'No'],
    // ['Option 1', 'Option 2', 'Option 3', 'Other'],
  ];

  List<String> answers = List.filled(10, ''); // Initialize with empty strings
  bool showError = false;

  void _saveAnswer(String answer) {
    setState(() {
      if (answer == 'Other') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController otherAnswerController =
                TextEditingController();

            return AlertDialog(
              title: const Text('Enter Your Answer'),
              content: TextField(
                controller: otherAnswerController,
              ),
              actions: [
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    String otherAnswer = otherAnswerController.text;
                    answers[currentQuestionIndex] = otherAnswer;
                    otherAnswerController.clear();
                    Navigator.pop(context);
                    showError = false; // Reset error state
                  },
                ),
                if (options[currentQuestionIndex].contains('Other'))
                  ElevatedButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      setState(() {
                        answers[currentQuestionIndex] = '';
                        showError = false; // Reset error state
                      });
                      Navigator.pop(context);
                    },
                  ),
              ],
            );
          },
        );
      } else {
        answers[currentQuestionIndex] = answer;
        showError = false; // Reset error state
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (answers[currentQuestionIndex].isEmpty) {
        showError = true; // Show error message if no answer is selected
      } else if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        // All questions answered, do something
        _submitAnswers();
      }
    });
  }

  void _previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      }
    });
  }

  void _submitAnswers() async {
    try {
      setState(() {
        showSpinner = true;
      });

      await _firestore.collection('userHabitts').doc(userId).set({
        'UserId': userId,
        'answerQ1': answers[0],
        'answerQ2': answers[1],
        'answerQ3': answers[2],
        'answerQ4': answers[3],
        'answerQ5': answers[4],
        'answerQ6': answers[5],
        'answerQ7': answers[6],
        'answerQ8': answers[7],
        'answerQ9': answers[8],
        'answerQ10': answers[9],
        'question1': questions[0],
        'question2': questions[1],
        'question3': questions[2],
        'question4': questions[3],
        'question5': questions[4],
        'question6': questions[5],
        'question7': questions[6],
        'question8': questions[7],
        'question9': questions[8],
        'question10': questions[9],
      });

      // Show a dialog to inform the user that their answer is saved
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('you are sign up successfully'),
            content: const Text(
                'Thank you for joining us , we know more about you can sign in to your account now '),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Get.to(const HomeScreen());
                },
              ),
            ],
          );
        },
      );

      setState(() {
        showSpinner = false;
      });
    } catch (e) {
      print('Error while submitting answers: $e');
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 70),
              const Text(
                'More About You ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  questions[currentQuestionIndex],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: options[currentQuestionIndex].map((option) {
                  return RadioListTile<String>(
                    title: DefaultTextStyle(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Text(option),
                    ),
                    value: option,
                    groupValue:
                        answers[currentQuestionIndex] == option ? option : null,
                    onChanged: (dynamic value) {
                      _saveAnswer(value as String);
                    },
                  );
                }).toList(),
              ),
              if (showError)
                const Text(
                  'Please select an answer.',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: answers[currentQuestionIndex].isEmpty
                        ? null
                        : _nextQuestion,
                    child: const Text('Next'),
                  ),
                  if (showError &&
                      options[currentQuestionIndex].contains('Other'))
                    ElevatedButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        setState(() {
                          answers[currentQuestionIndex] = '';
                          showError = false; // Reset error state
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
