import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleepwell/screens/profile/question_card.dart';

class MoreAboutYouScreen extends StatefulWidget {
  @override
  static String RouteScreen = 'MoreAboutYouScreen';

  const MoreAboutYouScreen({super.key});
  @override
  _MoreAboutYouScreenState createState() => _MoreAboutYouScreenState();
}

class _MoreAboutYouScreenState extends State<MoreAboutYouScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  List<String> _answers = List.filled(10, '');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _user = _auth.currentUser;
      if (_user != null) {
        await fetchSavedAnswers();
      }
    } catch (e) {
      print('Error retrieving user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> questions = [
    'Q1: How consistent is your sleep schedule?',
    'Q2: Do you have a regular bedtime routine?',
    'Q3: How often do you wake up tired in the morning?',
    'Q4: How much sleep do you usually get at night?',
    'Q5: How long does it take to fall asleep after you get into bed?',
    'Q6: Do you use your smartphone within 30 minutes before bedtime?',
    'Q7: Do you consume caffeine close to bedtime?',
    'Q8: When do you typically stop consuming coffee, tea, smoking, and other substances before bedtime?',
    'Q9: What activities do you typically engage in during the two hours leading up to your bedtime?',
    'Q10: Do you frequently consume food or snacks during the night?',
  ];

  List<List<String>> options = [
    ['Very consistent', 'Somewhat consistent', 'Inconsistent'],
    ['Yes', 'Occasionally', 'No'],
    ['Always', 'Usually', 'Sometimes', 'Rarely'],
    ['6 hours or less', '6-8 hours', '8-10 hours', '10 hours or more'],
    [
      'Several minutes',
      '10-15 minutes',
      '20-40 minutes',
      'Hard to fall asleep'
    ],
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
      'Engage in activities that may increase stress', // Removed leading space
      'Other'
    ],
    ['Yes', 'Occasionally', 'No'],
  ];

  // Method to fetch saved answers from Firebase
  Future<void> fetchSavedAnswers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('User behavior')
          .doc(_user!.uid)
          .get(const GetOptions(source: Source.server));
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _answers = [
            data['answerQ1'] ?? '',
            data['answerQ2'] ?? '',
            data['answerQ3'] ?? '',
            data['answerQ4'] ?? '',
            data['answerQ5'] ?? '',
            data['answerQ6'] ?? '',
            data['answerQ7'] ?? '',
            data['answerQ8'] ?? '',
            data['answerQ9'] ?? '',
            data['answerQ10'] ?? '',
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to get feedback based on user answers
  String getFeedback(int questionIndex, String userAnswer) {
    switch (questionIndex) {
      case 0: // Q1: How consistent is your sleep schedule?
        if (userAnswer == 'Very consistent')
          return "Your consistent sleep schedule is great! Keep maintaining this habit.";
        if (userAnswer == 'Somewhat consistent')
          return "Your schedule is somewhat consistent. Try to maintain a regular routine.";
        if (userAnswer == 'Inconsistent')
          return "An inconsistent schedule disrupts sleep. Try setting regular times.";
        break;
      case 1: // Q2: Do you have a regular bedtime routine?
        if (userAnswer == 'Yes')
          return "Great job maintaining a routine! It signals your brain that it's time to sleep.";
        if (userAnswer == 'Occasionally')
          return "Having a routine helps improve sleep quality. Try to do it more consistently.";
        if (userAnswer == 'No')
          return "Consider establishing a relaxing bedtime routine for better sleep.";
        break;
      case 2: // Q3: How often do you wake up tired in the morning?
        if (userAnswer == 'Always')
          return "Waking up tired frequently suggests insufficient or poor-quality sleep.";
        if (userAnswer == 'Usually' || userAnswer == 'Sometimes')
          return "Sometimes waking up tired is normal. Optimizing sleep could help.";
        if (userAnswer == 'Rarely')
          return "Rarely waking up tired suggests you're getting enough rest.";
        break;
      case 3: // Q4: How much sleep do you usually get at night?
        if (userAnswer == '6 hours or less')
          return "Getting less than 6 hours of sleep regularly can affect your health and mood. Try extending your sleep duration to at least 7-8 hours.";
        if (userAnswer == '6-8 hours')
          return "Your sleep duration is within the recommended range. Keep maintaining this balance for optimal health.";
        if (userAnswer == '8-10 hours')
          return "You’re getting a solid amount of sleep. Ensure your sleep quality is good too for the best benefits.";
        if (userAnswer == '10 hours or more')
          return "Sleeping more than 10 hours regularly could indicate low-quality sleep or underlying health issues. If you still feel tired, consult a health professional.";
        break;
      case 4: // Q5: How long does it take to fall asleep after you get into bed?
        if (userAnswer == 'Several minutes')
          return "Falling asleep quickly suggests that your body is well-prepared for sleep. Keep up with your healthy habits!";
        if (userAnswer == '10-15 minutes')
          return "You fall asleep within a normal range, which is a sign of good sleep hygiene.";
        if (userAnswer == '20-40 minutes')
          return "Taking 20-40 minutes to fall asleep may be a sign of restlessness. Try relaxation techniques before bed to help you wind down.";
        if (userAnswer == 'Hard to fall asleep')
          return "If you’re finding it hard to fall asleep regularly, try improving your sleep environment and reducing screen time before bed.";
        break;
      case 5: // Q6: Do you use your smartphone within 30 minutes before bedtime?
        if (userAnswer == 'Yes')
          return "Using your smartphone before bed can impact your ability to fall asleep quickly. Try to avoid screens at least 30 minutes before bed.";
        if (userAnswer == 'Occasionally')
          return "Occasional smartphone use before bed can still affect your sleep. Reducing this habit might help improve your sleep quality.";
        if (userAnswer == 'No')
          return "Great job avoiding your phone before bed! This can significantly improve your sleep quality.";
        break;
      case 6: // Q7: Do you consume caffeine close to bedtime?
        if (userAnswer == 'Yes')
          return "Caffeine close to bedtime can interfere with your ability to fall asleep. Try reducing caffeine intake later in the day.";
        if (userAnswer == 'Occasionally')
          return "While occasional caffeine use might not cause issues, limiting it closer to bedtime can help improve sleep.";
        if (userAnswer == 'No')
          return "Good job avoiding caffeine near bedtime! This helps your overall sleep quality.";
        break;
      case 7: // Q8: When do you typically stop consuming coffee, tea, smoking, and other substances before bedtime?
        if (userAnswer == 'I stop consuming at least 1-2 hours before bedtime')
          return "You’re on the right track by stopping consumption a couple of hours before bed. This helps your body wind down for restful sleep.";
        if (userAnswer == 'I stop consuming at least 3-4 hours before bedtime')
          return "Stopping consumption 3-4 hours before bed is excellent. It supports a good night’s rest.";
        if (userAnswer == 'I do not consume these substances at all')
          return "Avoiding these substances altogether is a great habit for improving sleep quality.";
        if (userAnswer == 'I use these substances right before bedtime')
          return "Using caffeine or other substances right before bed can delay sleep onset. Try reducing intake before sleep to improve your sleep.";
        break;
      case 8: // Q9: What activities do you typically engage in during the two hours leading up to your bedtime?
        if (userAnswer == 'Engage in relaxation techniques')
          return "Relaxation techniques before bed are a great way to help your body and mind prepare for sleep. Keep up the good work!";
        if (userAnswer == 'Engage in physical activity or exercise')
          return "Engaging in exercise too close to bedtime might make it harder to fall asleep. Try doing more calming activities before bed.";
        if (userAnswer == 'Engage in activities that may increase stress')
          return "Stressful activities before bed can interfere with your ability to fall asleep. Consider adding relaxing practices to your routine.";
        if (userAnswer == 'Other')
          return "Think about how your activities before bed impact your ability to relax. Engaging in calming activities can improve sleep quality.";
        break;
      case 9: // Q10: Do you frequently consume food or snacks during the night?
        if (userAnswer == 'Yes')
          return "Frequent snacking during the night may disrupt your sleep. Try to avoid eating right before bed to improve your rest.";
        if (userAnswer == 'Occasionally')
          return "Occasional snacking might not impact your sleep much, but avoiding heavy meals or snacks before bed can still be beneficial.";
        if (userAnswer == 'No')
          return "Great job avoiding nighttime snacks! This supports better sleep quality.";
        break;
      default:
        return '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF004AAD),
          title: const Text('More About You'),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF004AAD),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      return QuestionCard(
                        question: questions[index],
                        options: options[index],
                        answer: _answers[index],
                        onChanged: (String newValue) {
                          setState(() {
                            _answers[index] = newValue;
                          });
                        },
                        feedback: getFeedback(
                            index, _answers[index]), // Pass the feedback
                      );
                    },
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: saveAnswers,
          tooltip: 'Save Answers',
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  void saveAnswers() async {
    try {
      await _firestore.collection('User behavior').doc(_user!.uid).update({
        'answerQ1': _answers[0],
        'answerQ2': _answers[1],
        'answerQ3': _answers[2],
        'answerQ4': _answers[3],
        'answerQ5': _answers[4],
        'answerQ6': _answers[5],
        'answerQ7': _answers[6],
        'answerQ8': _answers[7],
        'answerQ9': _answers[8],
        'answerQ10': _answers[9],
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Answers saved!'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving answers: $e'),
      ));
    }
  }
}
