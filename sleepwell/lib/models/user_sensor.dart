class UserSensor {
  String sensorId;
  String userId;
  bool enable;

  UserSensor({
    required this.sensorId,
    required this.userId,
    required this.enable,
  });

  // Factory constructor to create an instance from a map
  factory UserSensor.fromMap(Map<dynamic, dynamic> data) {
    return UserSensor(
      sensorId: data['sensorId'] ?? '',
      userId: data['userId'] ?? '',
      enable: data['enable'] ?? false,
    );
  }

  // Method to convert the object to a map (useful for caching or Firebase storage)
  Map<String, dynamic> toMap() {
    return {
      'sensorId': sensorId,
      'userId': userId,
      'enable': enable,
    };
  }
}
