import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/feedbacke_notification_model.dart';

class FeedbackeNotificationController extends GetxController {
  // قائمة من الإشعارات، تكون RxList حتى يتم ملاحظة أي تغيير في البيانات
  RxList<FeedbackeNotificationModel> notifications = RxList();

  Future<void> fetchNotifications(String userId) async {
    try {
      // جلب البيانات من فايربيس باستخدام استعلام يعتمد على UserId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('feedback')
          .where('UserId', isEqualTo: userId)
          .get();

      // تحويل البيانات إلى قائمة من كائنات FeedbackeNotificationModel
      notifications.value = querySnapshot.docs
          .map((doc) => FeedbackeNotificationModel.fromMap(
              doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }
}
