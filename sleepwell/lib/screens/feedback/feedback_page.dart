import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sleepwell/screens/home_screen.dart';
import '../../push_notification_service.dart';

// late String predictedQuality;
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  List<String> answers = List.filled(7, ''); // Initialize with empty strings
  String predictedQuality = "";
  List<String> reasons = List.filled(7, '');
  List<String> recommendations = List.filled(7, '');

  bool showError = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentQuestionIndex = 0;
  bool _canProceed = false;
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
        showSpinner = true;
      });

      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          userId = user.uid;
          email = user.email!;
        });
      }

      setState(() {
        showSpinner = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        showSpinner = false;
      });
    }
  }

  List<String> questions = [
    'Did you experience high levels of stress or anxiety before bedtime?'.tr,
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

  Future<void> showSleepQualityDialog(
      BuildContext context, predictedQuality, reasons, recommendations) async {
    // Prepare notification message
    String notificationMessage = 'Your Sleep Quality is: $predictedQuality \n';
    // if (predictedQuality == 'Poor' || predictedQuality == 'Average') {
    //   notificationMessage +=
    //       '\nReason: ${reasons.join(', ')}\nAdvice: ${recommendations.join(', ')}';
    // }
    Get.offAll(const HomeScreen());

    if (predictedQuality == 'Poor' || predictedQuality == 'Average') {
      await PushNotificationService
          .showNotificationWithReasonsAndRecommendations(
        title: notificationMessage,
        // body: 'Your Sleep Quality is: $predictedQuality',
        reasons: reasons, // تمرير القائمة هنا
        recommendations: recommendations, // تمرير القائمة هنا
        schedule: true,
        interval: 60,
        actionButton: [
          NotificationActionButton(
              key: 'DailyNotification',
              label: 'Go To Daily Notification Screen')
        ],
      );

      // await PushNotificationService.showNotification(
      //   title: notificationMessage,
      //   body: '\nReason: ${reasons.join(', \n')}',
      //   summary: '\nAdvice: ${recommendations.join(', \n')}',
      //   schedule: true,
      //   interval: 60,
      // );
    } else {
      await PushNotificationService.showNotification(
        title: 'Sleep Well Quality',
        body: notificationMessage,
        schedule: true,
        interval: 60,
        actionButtons: [
          NotificationActionButton(
              key: 'DailyNotification',
              label: 'Go To Daily Notification Screen')
        ],
      );
    }
  }

  void evaluateSleepQuality(BuildContext context) {
    // بناء البيانات الخاصة بجودة النوم، الأسباب، والنصائح
    String predictedQuality = 'Poor'; // أو 'Average' أو 'Good'
    List<String> reasons = [
      'Too much screen time before bed',
      'Stress or anxiety',
      'Late caffeine intake'
    ];
    List<String> recommendations = [
      'Avoid screens 1 hour before bed',
      'Practice relaxation techniques',
      'Limit caffeine intake in the evening'
    ];

    // استدعاء الدالة لعرض الإشعار بناءً على البيانات
    showSleepQualityDialog(context, predictedQuality, reasons, recommendations);
  }

  Future<void> _getFeedback(BuildContext context) async {
    final url = Uri.parse(
        'https://my-sleep-quality-api-5903a0effd39.herokuapp.com/predict');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'answers': answers}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final String sleepQuality = result['predicted_quality'];

      // Casting dynamic list to List<String>
      final List<String> reasons = List<String>.from(result['reasons'] ?? []);
      final List<String> recommendations =
          List<String>.from(result['recommendations'] ?? []);
      _firestore.collection('feedback').add({
        'UserId': userId,
        'answers': answers,
        'timestamp': DateTime.now(),
        'sleepQuality': sleepQuality,
        'reasons': reasons,
        'recommendations': recommendations,
      });
      showSleepQualityDialog(context, sleepQuality, reasons, recommendations);
    } else {
      print('Failed to get a response. Status code: ${response.statusCode}');
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
                      onPressed: () async => await _getFeedback(context),
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
