import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/feedbacke_notification_model.dart';

class FeedbackeNotificationController extends GetxController {
  RxList<FeedbackeNotificationModel> notifications = RxList();
  var isLoading = true.obs;

  Future<void> fetchNotifications(String userId) async {
    try {
      isLoading(true);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('feedback')
          .where('UserId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      notifications.value = querySnapshot.docs
          .map((doc) => FeedbackeNotificationModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      // log("Fetched Notifications: ${notifications.join(', ')}");
      update();
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteNotification(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(docId)
          .delete();
      notifications.removeWhere((notification) => notification.id == docId);
      update();

      log("Deleted Notification ID: $docId");
      Get.defaultDialog(
        title: "Success",
        middleText: "Notification deleted successfully!",
        textConfirm: "Close",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          Get.back();
        },
      );
    } catch (e) {
      print("Error deleting notification: $e");
    }
  }
}
