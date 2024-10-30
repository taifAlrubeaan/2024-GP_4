class Sensor {
  String sensorId;
  int temperatura;
  int spO2;
  int heartRate;

  Sensor({
    required this.sensorId,
    required this.temperatura,
    required this.spO2,
    required this.heartRate,
  });

  factory Sensor.fromMap(Map<dynamic, dynamic> data) {
    return Sensor(
      // تحويل sensorId إلى String
      sensorId: data['sensorId'].toString(),
      temperatura: data['Temperatura'] ?? 0,
      spO2: data['SpO2'] ?? 0,
      heartRate: data['HeartRate'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sensorId': sensorId,
      'Temperatura': temperatura,
      'SpO2': spO2,
      'HeartRate': heartRate,
    };
  }
}
