// more_about_you_screen.dart
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
    'Q3:How often do you wake up tired in the morning?',
    'Q4:How much sleep do you usually get at night?',
    'Q5:How long does it take to fall asleep after you get into bed?',
    'Q6: Do you use your smartphone within 30 minutes before bedtime?',
    'Q7:Do you consume caffeine close to bedtime?',
    'Q8:When do you typically stop consuming coffee, tea, smoking, and other substances before bedtime?',
    'Q9:What activities do you typically engage in during the two hours leading up to your bedtime?',
    'Q10:Do you frequently consume food or snacks during the night?',
  ];

  List<List<String>> options = [
    ['Very consistent', 'Somewhat consistent', 'Inconsistent'],
    ['Yes', 'Occasionally', 'No'],
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
  ];

  Future<void> fetchSavedAnswers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('userHabitts')
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey, // Change this to your desired background color
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
                        onChanged: (value) {
                          setState(() {
                            _answers[index] = value;
                          });
                        },
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
      await _firestore.collection('userHabitts').doc(_user!.uid).update({
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
