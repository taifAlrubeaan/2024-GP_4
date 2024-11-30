class BeneficiaryModel {
  final String id;
  final String name;
  // final String watch;
  final String userId;

  BeneficiaryModel({
    required this.id,
    required this.name,
    // required this.watch,
    required this.userId,
  });

  factory BeneficiaryModel.fromFirestore(Map<String, dynamic> data, String id) {
    // التحقق من أن البيانات تحتوي على الحقول المطلوبة
    if (data['name'] == null ||
        // data['watch'] == null ||
        data['userid'] == null) {
      throw Exception('Missing required fields in Firestore data');
    }

    return BeneficiaryModel(
      id: id,
      name: data['name'],
      // watch: data['watch'],
      userId: data['userid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      // 'watch': watch,
      'userid': userId,
    };
  }
}
