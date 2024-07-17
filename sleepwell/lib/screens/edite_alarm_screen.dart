import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:sleepwell/alarm.dart';
import 'package:sleepwell/main.dart';
import 'package:sleepwell/models/list_of_music.dart';
import 'package:sleepwell/widget/sounds_widget.dart';

class EditAlarmScreen extends StatefulWidget {
  @override
  _EditAlarmScreenState createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  String selectedSoundPath = musicList[0].musicPath;
  String selectedMission = 'Default';
  String selectedMath = 'easy';
  bool isMissionStopVisible = false;
  bool isMathMissionSelected = false;
  String mathMissionDifficulty = 'Easy';

  void saveSettings() {
    prefs.setString("selectedMission", selectedMission);
    prefs.setString("selectedMath", selectedMath);
    prefs.setString("selectedSoundPath", selectedSoundPath);
    setState(() {});
  }

  void loadSettings() {
    selectedSoundPath =
        prefs.getString("selectedSoundPath") ?? musicList[0].musicPath;
    selectedMission = prefs.getString("selectedMission") ?? "Default";
    selectedMath = prefs.getString("selectedMath") ?? "easy";
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final soundsWidget = SoundsWidget(
      initSoundPath: selectedSoundPath,
      onChangeSound: (soundPath) {
        selectedSoundPath = soundPath ?? musicList[0].musicName;
      },
    );
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Alarm',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF004AAD),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.08), // Responsive padding
          child: ListView(
            padding: EdgeInsets.symmetric(
                horizontal:
                    screenWidth * 0.04), // Responsive horizontal padding
            shrinkWrap: true,
            children: [
              const SizedBox(height: 15),
              ResponsiveText(
                text: 'Select Alarm Sound',
                baseFontSize: 25,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01), // Responsive padding
                child: soundsWidget,
              ),
              const SizedBox(height: 30),
              ResponsiveText(
                text: 'Alarm Type',
                baseFontSize: 25,
              ),
              const SizedBox(height: 10),
              getRadioListTile(
                value: "Default",
                groupValue: selectedMission,
                onChanged: (value) =>
                    setState(() => selectedMission = value ?? "Default"),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                title: 'Sound only',
                icon: Icons.alarm,
              ),
              const SizedBox(height: 10),
              getRadioListTile(
                value: "Math Problem",
                groupValue: selectedMission,
                onChanged: (value) =>
                    setState(() => selectedMission = value ?? "Default"),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                icon: Icons.calculate_rounded,
                title: 'Sound & Math Problem',
              ),
              getRadioListTile(
                value: "easy",
                groupValue:
                    selectedMission == "Math Problem" ? selectedMath : "",
                onChanged: (value) =>
                    setState(() => selectedMath = value ?? "easy"),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.058), // Adjusted padding
                icon: Icons.sim_card,
                title: 'easy',
                fontSize: 17,
              ),
              getRadioListTile(
                value: "difficult",
                groupValue:
                    selectedMission == "Math Problem" ? selectedMath : "",
                onChanged: (value) =>
                    setState(() => selectedMath = value ?? "easy"),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.058), // Adjusted padding
                icon: Icons.difference,
                title: 'difficult',
                fontSize: 17,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await soundsWidget.audioPlayer.pause();
                        Get.back();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await soundsWidget.audioPlayer.pause();
                        saveSettings();
                        await AppAlarm.initAlarms();
                        await AppAlarm.updateStoredWakeUpAlarmSound();
                        Get.back();
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final double
      baseFontSize; // Base font size for a reference screen width like 375 pixels

  const ResponsiveText({
    Key? key,
    required this.text,
    this.baseFontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.width / 375;
    return Text(
      text,
      style: TextStyle(
        fontSize: baseFontSize * scaleFactor,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

Widget getRadioListTile({
  required String value,
  required String groupValue,
  required EdgeInsets padding,
  required void Function(String?)? onChanged,
  required IconData icon,
  required String title,
  double fontSize = 19,
}) {
  return SizedBox(
    height: 45,
    child: RadioListTile(
      value: value,
      activeColor: Colors.white,
      groupValue: groupValue,
      onChanged: onChanged,
      contentPadding: padding,
      title: Row(
        children: [
          Icon(
            icon,
            color: Color.fromARGB(255, 188, 178, 178),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ],
      ),
    ),
  );
}
