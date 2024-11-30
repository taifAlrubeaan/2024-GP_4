import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/alarm.dart';
import 'package:sleepwell/models/list_of_music.dart';
import 'package:sleepwell/widget/sounds_widget.dart';
import '../models/alarm_data.dart';

class EditAlarmScreen extends StatefulWidget {
  final AlarmData? alarm;

  const EditAlarmScreen({super.key, this.alarm});

  @override
  _EditAlarmScreenState createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  String selectedSoundPath = musicList[0].musicPath;
  String selectedMission = 'Default';
  String selectedMath = 'easy';
  late bool isGeneralSettings;

  @override
  void initState() {
    super.initState();
    isGeneralSettings = widget.alarm == null;
    log("Initialized as ${isGeneralSettings ? 'General Settings' : 'Alarm-Specific Settings'}");

    if (isGeneralSettings) {
      _loadDefaultSettings();
    } else {
      _loadAlarmSettings();
    }
  }

  Future<void> _loadDefaultSettings() async {
    Map<String, String> settings = await AppAlarm.getDefaultSettings();
    setState(() {
      selectedSoundPath = settings['soundPath'] ?? musicList[0].musicPath;
      selectedMission = settings['mission'] ?? 'Default';
      selectedMath = settings['mathDifficulty'] ?? 'easy';
    });
  }

  void _loadAlarmSettings() {
    setState(() {
      selectedSoundPath =
          widget.alarm?.selectedSoundPath ?? musicList[0].musicPath;
      selectedMission = widget.alarm?.selectedMission ?? 'Default';
      selectedMath = widget.alarm?.selectedMath ?? 'easy';
    });
  }

  Future<void> _saveSettings() async {
    if (isGeneralSettings) {
      await AppAlarm.saveDefaultSettings(
        soundPath: selectedSoundPath,
        mission: selectedMission,
        mathDifficulty: selectedMath,
      );
      AppAlarm.initAlarms(); // Update alarms globally
      await AppAlarm.getAlarms();
      log("Default settings saved.");
    } else {
      widget.alarm?.selectedSoundPath = selectedSoundPath;
      widget.alarm?.selectedMission = selectedMission;
      widget.alarm?.selectedMath = selectedMath;

      AppAlarm.updateAlarmSettings(
        alarmId: widget.alarm!.alarmId,
        soundPath: selectedSoundPath,
        mission: selectedMission,
        mathDifficulty: selectedMath,
      );
      AppAlarm.initAlarms(); // Update alarms globally
      await AppAlarm.getAlarms();
      log("Settings saved for alarm ID: ${widget.alarm?.alarmId}");
    }

    Get.back(); // Close the screen
  }

  Future<void> _showSaveConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Changes'),
          content: const Text('Do you want to save the updated settings?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final soundsWidget = SoundsWidget(
      initSoundPath: selectedSoundPath,
      onChangeSound: (soundPath) {
        setState(() {
          selectedSoundPath = soundPath ?? musicList[0].musicPath;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGeneralSettings ? 'Edit General Settings' : 'Edit Alarm Settings',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
            children: [
              const SizedBox(height: 15),
              const Text(
                'Select Alarm Sound',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: soundsWidget,
              ),
              const SizedBox(height: 30),
              const Text(
                'Alarm Type',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildMissionTypeSelector(),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showSaveConfirmationDialog,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionTypeSelector() {
    return Column(
      children: [
        getRadioListTile(
          value: "Default",
          groupValue: selectedMission,
          onChanged: (value) =>
              setState(() => selectedMission = value ?? "Default"),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          icon: Icons.alarm,
          title: 'Sound only',
        ),
        getRadioListTile(
          value: "Math Problem",
          groupValue: selectedMission,
          onChanged: (value) =>
              setState(() => selectedMission = value ?? "Default"),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          icon: Icons.calculate,
          title: 'Sound & Math Problem',
        ),
        if (selectedMission == "Math Problem") ...[
          getRadioListTile(
            value: "easy",
            groupValue: selectedMath,
            onChanged: (value) =>
                setState(() => selectedMath = value ?? "easy"),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            icon: Icons.star_border,
            title: 'Easy',
          ),
          getRadioListTile(
            value: "difficult",
            groupValue: selectedMath,
            onChanged: (value) =>
                setState(() => selectedMath = value ?? "difficult"),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            icon: Icons.star,
            title: 'Difficult',
          ),
        ],
      ],
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
