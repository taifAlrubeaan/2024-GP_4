class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String age;
  final String fcmToken;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.fcmToken,
  });

  // Converts a UserModel to a Map (to JSON)
  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'Fname': firstName,
      'Lname': lastName,
      'Email': email,
      'Age': age,
      'FCM_Token': fcmToken,
    };
  }

  // Factory constructor to create a UserModel from a Map (from JSON)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['UserId'] ?? '',
      firstName: map['Fname'] ?? '',
      lastName: map['Lname'] ?? '',
      email: map['Email'] ?? '',
      age: map['Age'] ?? '',
      fcmToken: map['FCM_Token'] ?? '',
    );
  }

  // Aliases for toJson and fromJson
  Map<String, dynamic> toJson() => toMap();
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel.fromMap(json);
}
