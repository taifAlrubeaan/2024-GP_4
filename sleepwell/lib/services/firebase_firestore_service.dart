import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAlarm(
      String bedtime,
      String wakeupTime,
      String cycles,
      String userId,
      String? beneficiaryId,
      bool isForBeneficiary,
      String sensorId) async {
    await _firestore.collection('alarms').add({
      'bedtime': bedtime,
      'wakeup_time': wakeupTime,
      'num_of_cycles': cycles,
      'added_day': DateTime.now().day,
      'added_month': DateTime.now().month,
      'added_year': DateTime.now().year,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': userId,
      'beneficiaryId': beneficiaryId,
      'isForBeneficiary': isForBeneficiary,
      sensorId: sensorId,
    });

   }
   
     Future<void> updateBedtime({
      required String userId,
      required String newBedtime,
    }) async {
      // استعلام للحصول على المستند بناءً على معرف المستخدم
      QuerySnapshot snapshot = await _firestore
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .limit(1) // للحصول على مستند واحد فقط
          .get();

      // التحقق من وجود مستند مطابق
      if (snapshot.docs.isNotEmpty) {
        // الحصول على معرف المستند
        String documentId = snapshot.docs.first.id;

        // تحديث حقل الـ bedtime في المستند
        await _firestore.collection('alarms').doc(documentId).update({
          'bedtime': newBedtime,
          'timestamp': FieldValue.serverTimestamp(), // لإضافة وقت التحديث
        });
      } else {
        print('No matching document found for userId: $userId');
      }
    }
 
}
