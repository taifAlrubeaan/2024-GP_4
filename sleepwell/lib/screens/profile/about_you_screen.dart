import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutYouPage extends StatefulWidget {
  @override
  _AboutYouPageState createState() => _AboutYouPageState();
}

class _AboutYouPageState extends State<AboutYouPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  User? _currentUser;
  bool _isLoading = false;
  String _firstName = '';
  String _lastName = '';
  String _age = '';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      setState(() {
        _isLoading = true;
      });

      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        setState(() {
          _currentUser = user;
        });

        await _getUserInfo();
      }
    } catch (e) {
      print('Error retrieving user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserInfo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      DocumentSnapshot userSnapshot =
          await _firestore.collection('Users').doc(_currentUser!.uid).get();

      String firstName = userSnapshot.get('Fname');
      String lastName = userSnapshot.get('Lname');
      String age = userSnapshot.get('Age') ?? '';

      setState(() {
        _firstName = firstName;
        _lastName = lastName;
        _age = age;
        _firstNameController.text = firstName;
        _lastNameController.text = lastName;
        _ageController.text = age;
      });
    } catch (e) {
      print('Error retrieving user information: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserInfo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      String firstName = _firstNameController.text;
      String lastName = _lastNameController.text;
      String age = _ageController.text;

      await _firestore.collection('Users').doc(_currentUser!.uid).update({
        'Fname': firstName,
        'Lname': lastName,
        'Age': age,
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Your information has been updated.'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  // Navigator.pop(context);
                  Get.back();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        _isEditing = false;
        _firstName = firstName;
        _lastName = lastName;
        _age = age;
      });
    } catch (e) {
      print('Error updating user information: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        title: const Text('About You'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                _isEditing = true;
                _firstNameController.text = _firstName;
                _lastNameController.text = _lastName;
                _ageController.text = _age;
              });
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Information',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _firstNameController,
                      enabled: _isEditing,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _lastNameController,
                      enabled: _isEditing,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _ageController,
                      enabled: _isEditing,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (_isEditing)
                      ElevatedButton(
                        onPressed: _updateUserInfo,
                        child: const Text('Save'),
                      ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'On this page, you can click on the edit icon to modify or update your information.',
                      style: TextStyle(
                        fontSize: 15.0,
                        //fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 232, 106, 152),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
