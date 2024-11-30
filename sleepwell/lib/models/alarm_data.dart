import 'dart:developer';

class AlarmData {
  int alarmId; // Identifier for each alarm
  String bedtime;
  String optimalWakeTime;
  String name;
  String sensorId;
  String userId;
  String beneficiaryId;
  bool isForBeneficiary;
  String selectedSoundPath; // Specific sound for this alarm
  String selectedMission; // Alarm mission type
  String selectedMath; // Math difficulty

  AlarmData({
    required this.alarmId,
    required this.userId,
    required this.beneficiaryId,
    required this.bedtime,
    required this.optimalWakeTime,
    required this.name,
    required this.sensorId,
    required this.isForBeneficiary,
    // this.selectedSoundPath = 'musicList[0].musicPath',
    this.selectedSoundPath = 'assets/music/mozart.mp3',
    this.selectedMission = 'Default',
    this.selectedMath = 'easy',
  });

  /// Factory constructor to initialize from JSON
  factory AlarmData.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('uid')) {
      log('Warning: userId (uid) is missing in Firestore document data');
    }
    return AlarmData(
      alarmId: json['alarmId'] ?? 0, // Default to 0 if not provided
      userId: json['uid'] ?? '',
      beneficiaryId: json['beneficiaryId'] ?? '',
      bedtime: json['bedtime'] ?? '',
      optimalWakeTime: json['wakeup_time'] ?? '',
      name: json['name'] ?? '',
      sensorId: json['sensorId'] ?? '',
      isForBeneficiary: json['isForBeneficiary'] ?? false,
      selectedSoundPath: json['selectedSoundPath'],
      selectedMission: json['selectedMission'],
      selectedMath: json['selectedMath'],
    );
  }

  /// Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'alarmId': alarmId,
      'bedtime': bedtime,
      'wakeup_time': optimalWakeTime,
      'name': name,
      'sensorId': sensorId,
      'uid': userId,
      'beneficiaryId': beneficiaryId,
      'isForBeneficiary': isForBeneficiary,
      'selectedSoundPath': selectedSoundPath,
      'selectedMission': selectedMission,
      'selectedMath': selectedMath,
    };
  }
}
