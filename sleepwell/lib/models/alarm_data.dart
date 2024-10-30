// alarm_data.dart

class AlarmData {
    String bedtime;
  final String optimalWakeTime;
  final String name;
  final bool usertype;
  final String sensorId;
  final String userId;

  AlarmData({
    required this.userId,
    required this.bedtime,
    required this.optimalWakeTime,
    required this.name,
    required this.usertype,
    required this.sensorId,
  });

  // Convert a Map to an AlarmData instance
  factory AlarmData.fromJson(Map<String, dynamic> json) {
    return AlarmData(
      userId: json['userId'] ?? "0",
      bedtime: json['bedtime'] ?? '', // Default empty string if null
      optimalWakeTime: json['optimalWakeTime'] ?? '',
      name: json['name'] ?? '',
      usertype: json['usertype'] ?? false, // Default to false if null
      sensorId: json['sensorId'] ?? '',
    );
  }

  // Convert an AlarmData instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'bedtime': bedtime,
      'optimalWakeTime': optimalWakeTime,
      'name': name,
      'usertype': usertype,
      'sensorId': sensorId,
      'userId': userId
    };
  }
}
