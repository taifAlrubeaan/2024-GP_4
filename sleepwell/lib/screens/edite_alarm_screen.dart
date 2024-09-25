import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:sleepwell/alarm.dart';
import 'package:sleepwell/main.dart';
import 'package:sleepwell/models/list_of_music.dart';
import 'package:sleepwell/widget/sounds_widget.dart';

class EditAlarmScreen extends StatefulWidget {
  const EditAlarmScreen({super.key});

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
  // final audioPlayer = AudioPlayer();

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Alarm',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: const Color(0xFF004AAD),
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
          padding: const EdgeInsets.all(30.0),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            children: [
              const SizedBox(height: 15),
              const Text(
                'Select Alarm Sound',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: soundsWidget),
              // const Divider(),
              const SizedBox(height: 30),

              // choose the method of pause the alarm
              const Text(
                'Alarm Type',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255)),
              ),
              const SizedBox(height: 20),
              getRadioListTile(
                value: "Default",
                groupValue: selectedMission,
                onChanged: (value) =>
                    setState(() => selectedMission = value ?? "Default"),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                title: 'Sound only',
                icon: Icons.alarm,
              ),
              /* const ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 68),
                leading: Icon(
                  Icons.pause_circle_outline_sharp,
                  size: 20,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                title: Text(
                  'Stop',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),*/
              const SizedBox(height: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 58),
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
                padding: const EdgeInsets.symmetric(horizontal: 58),
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
                          color: Color.fromARGB(255, 255, 255, 255),
                          // backgroundColor: Color.fromARGB(0, 9, 42, 232),
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
                          color: Color.fromARGB(255, 255, 255, 255),
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
            color: const Color.fromARGB(255, 188, 178, 178),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ],
      ),
    ),
  );
}
