import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sleepwell/screens/alarm_screen.dart';

// late String predictedQuality;
class FeedbackPage extends StatefulWidget {
  static String RouteScreen = 'feedback';

  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  List<String> answers = List.filled(7, ''); // Initialize with empty strings
  bool showError = false;
  // Existing variables...
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentQuestionIndex = 0;
  bool _canProceed = false;
  /////////Taif Edite this part ///////////////
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

      final user = await _auth.currentUser;
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

  final String apiUrl =
      "https://my-sleep-quality-api-5903a0effd39.herokuapp.com/predict/";
  final String apiToken =
      'HRKU-da62ae22-3861-4deb-95c6-059e8a9b8425'; // Replace with your token

  List<String> questions = [
    'Did you experience high levels of stress or anxiety before bedtime?',
    'Did you use nicotine products close to bedtime?',
    'Did you use electronic devices before bedtime?',
    'Is your bedroom?',
    'Is the temperature in your bedroom?',
    'Did you consume any caffeinated beverages within 4 hours before bedtime?',
    'Did you consume food within 2 hours before bedtime?',
  ];

  List<List<String>> options = [
    ['Yes', 'No'],
    ['Yes', 'No'],
    ['Yes', 'No'],
    ['Quiet', 'Moderately noisy', 'Noisy'],
    ['Cool', 'Warm', 'Hot'],
    ['Yes', 'No'],
    ['Yes', 'No'],
  ];

  void _saveAnswer(String answer) {
    setState(() {
      answers[_currentQuestionIndex] = answer;
      showError = false;

      if (_currentQuestionIndex == questions.length - 1 &&
          answers.every((answer) => answer.isNotEmpty)) {
        _canProceed = true;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (answers[_currentQuestionIndex].isEmpty) {
        showError = true;
      } else if (_currentQuestionIndex < questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _canProceed = true;
      }
    });
  }

  void _previousQuestion() {
    setState(() {
      if (_currentQuestionIndex > 0) {
        _currentQuestionIndex--;
      }
    });
  }

  Future<String> queryModel(Map<String, dynamic> payload) async {
    print('queryModel: Starting to send payload to API: $payload');

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiToken",
        },
        body: json.encode(payload),
      );

      print('queryModel: Response status code: ${response.statusCode}');
      print('queryModel: Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('predicted_sleep_quality') &&
            jsonResponse['predicted_sleep_quality'] != null) {
          return jsonResponse['predicted_sleep_quality'];
        } else {
          throw Exception(
              'Missing or null predicted_sleep_quality in response');
        }
      } else {
        print('queryModel: Failed to query model: ${response.statusCode}');
        print('queryModel: Response body: ${response.body}');
        throw Exception(
            'queryModel: Failed to query model: ${response.statusCode}');
      }
    } catch (e) {
      print('queryModel: Exception occurred while querying model: $e');
      throw e;
    }
  }

  void _getFeedback() async {
    Map<String, dynamic> payload = {
      "Q1": answers[0],
      "Q2": answers[1],
      "Q3": answers[2],
      "Q4": answers[3],
      "Q5": answers[4],
      "Q6": answers[5],
      "Q7": answers[6],
    };

    print('Getting feedback with payload: $payload');

    try {
      String predictedQuality = await queryModel(payload);
      print('Predicted sleep quality: $predictedQuality');
      _firestore.collection('feedback').add({
        //Taif add user Id
        'UserId': userId,
        'answers': answers,
        'timestamp': DateTime.now(),
        'predictedQuality': predictedQuality,
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Predicted Sleep Quality'),
            content: Text('The predicted sleep quality is: $predictedQuality'),
            // title: const Text('Feedback Submitted'),
            // content: const Text('Thank you for your feedback!'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.offAll(AlarmScreen());
                  // Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('Feedback Submitted'),
      //       content: const Text('Thank you for your feedback!'),
      //       actions: [
      //         ElevatedButton(
      //             child: const Text('OK'),
      //             onPressed: () {
      //               // Navigator.push(
      //               //   context,
      //               //   MaterialPageRoute(builder: (context) => const MyHomePage()),
      //               // );
      //               // _getFeedback();

      //               Get.to(AlarmScreen());
      //             }),
      //       ],
      //     );
      //   },
      // );
    } catch (e) {
      print('Error querying model: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Failed to predict sleep quality. Please try again.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _submitFeedback() async {
    _getFeedback();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feedback Submitted'),
          content: const Text('Thank you for your feedback!'),
          actions: [
            ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const MyHomePage()),
                  // );
                  // _getFeedback();

                  Get.to(AlarmScreen());
                }),
          ],
        );
      },
    );
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
                'Sleep Feedbacks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                questions[_currentQuestionIndex],
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: options[_currentQuestionIndex].map((option) {
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
                    groupValue: answers[_currentQuestionIndex] == option
                        ? option
                        : null,
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
                  if (_currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: _previousQuestion,
                      child: const Text('Back'),
                    ),
                  if (_currentQuestionIndex < questions.length - 1)
                    ElevatedButton(
                      onPressed: answers[_currentQuestionIndex].isEmpty
                          ? null
                          : _nextQuestion,
                      child: const Text('Next'),
                    ),
                  if (_currentQuestionIndex == questions.length - 1 &&
                      _canProceed)
                    ElevatedButton(
                      onPressed: _getFeedback,
                      child: const Text('Submit Feedback'),
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
