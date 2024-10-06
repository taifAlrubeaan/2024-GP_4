import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sleepwell/widget/indicator.dart'; // تأكد من إضافة هذا الاستيراد لمخطط FL Chart

class FeedbackNotificationWeeklyScreen extends StatefulWidget {
  const FeedbackNotificationWeeklyScreen({super.key});

  @override
  State<FeedbackNotificationWeeklyScreen> createState() =>
      _FeedbackNotificationWeeklyScreenState();
}

class _FeedbackNotificationWeeklyScreenState
    extends State<FeedbackNotificationWeeklyScreen> {
  final List<Map<String, dynamic>> notifications = [];
  List<PieChartSectionData> pieSectionsWeekly = [];
  List<Color> weeklyColors = [
    const Color.fromRGBO(54, 244, 101, 1),
    Colors.red,
    const Color.fromARGB(255, 155, 54, 244),
    const Color.fromARGB(255, 7, 59, 245),
    Colors.green,
    Colors.blue,
    Colors.yellow
  ];
  int totalReasons = 0; // لحساب إجمالي الأسباب

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    print(":::::::::::::::::::::::::::userId::::::::::::::::;");
    print(userId);
    print(":::::::::::::::::::::::::::userId::::::::::::::::;");
    if (userId != null) {
      try {
        QuerySnapshot notificationSnapshot = await FirebaseFirestore.instance
            .collection('weeklyNotifications')
            .where('userId', isEqualTo: userId)
            .orderBy('date', descending: true)
            .get();

        setState(() {
          notifications.clear();
          notifications.addAll(notificationSnapshot.docs.map((doc) {
            // طباعة البيانات المسترجعة للتحقق منها
            // print("Notification Data: ${doc.data()}");
            debugPrint("Notification Data: ${doc.data()}", wrapWidth: 1024);

            return {
              'date': (doc['date'] as Timestamp).toDate(),
              'reasons': Map<String, int>.from(doc['reasons']),
              'repeatedReasonsWithRecommendations':
                  doc['repeatedReasonsWithRecommendations'] != null
                      ? List<Map<String, String>>.from((doc[
                              'repeatedReasonsWithRecommendations'] as List)
                          .map((item) => Map<String, String>.from(item as Map)))
                      : [],
            };
          }));
        });

        _calculatePieChartData(); // حساب بيانات المخطط الدائري
      } catch (e) {
        print('Error fetching notifications: $e');
      }
    }
  }

  void _calculatePieChartData() {
    // إنشاء خريطة لحساب تكرار الأسباب
    Map<String, int> reasonCounts = {};

    for (var notification in notifications) {
      Map<String, int> reasons = notification['reasons'];
      reasons.forEach((key, value) {
        reasonCounts[key] = (reasonCounts[key] ?? 0) + value;
        totalReasons += value; // تحديث إجمالي الأسباب
      });
    }

    // تحويل الخريطة إلى قائمة مخطط دائري
    pieSectionsWeekly = reasonCounts.entries.map((entry) {
      return PieChartSectionData(
        color: weeklyColors[reasonCounts.keys.toList().indexOf(entry.key) %
            weeklyColors.length],
        value: entry.value.toDouble(),
        radius: 45, // Increase radius for better visibility
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام التاريخ الافتراضي في حالة عدم وجود إشعارات
    DateTime displayDate = notifications.isNotEmpty
        ? notifications[0]['date'] as DateTime
        : DateTime.now(); // تاريخ افتراضي

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        elevation: 50,
        title: const Text(
          'Weekly Notifications',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // تعديل المسافات هنا
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                height: 250, // حجم ثابت للطول
                margin: const EdgeInsets.all(8), // تقليل المسافة الخارجية
                decoration: BoxDecoration(
                  color: const Color(0xFFBBDEFB),
                  borderRadius: BorderRadius.circular(25), // حواف مقوسة
                ),
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.all(4.0), // إضافة مسافة حول النص
                        child: Row(
                          children: [
                            Text(
                              "Percentage of weekly effects on sleep\n   for $displayDate",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      // تعديل في المسافة بين العناوين والـ Pie Chart
                      // const SizedBox(height: 8), // تقليل المسافة هنا
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 180, // تقليل عرض المخطط
                            height: 180, // تقليل ارتفاع المخطط
                            child: PieChart(
                              PieChartData(
                                sections: pieSectionsWeekly,
                                centerSpaceRadius: 20,
                                sectionsSpace: 2,
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              pieSectionsWeekly.length,
                              (index) {
                                String reason = notifications.isNotEmpty
                                    ? notifications[0]['reasons']
                                        .keys
                                        .toList()[index]
                                    : 'Unknown Reason';
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: Indicator(
                                    color: weeklyColors[
                                        index % weeklyColors.length],
                                    text: reason, // عرض العنوان فقط
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  DateTime notificationDate = notifications[index]['date'];
                  Map<String, int> reasons = notifications[index]['reasons'];

                  // التأكد من وجود قائمة 'repeatedReasonsWithRecommendations'
                  List<Map<String, String>> recommendationsList =
                      notifications[index]
                          ['repeatedReasonsWithRecommendations'];

                  // عرض المؤثرات والتوصيات
                  List<Widget> reasonWidgets =
                      recommendationsList.map((recommendationEntry) {
                    String reason =
                        recommendationEntry['reason'] ?? 'Unknown Reason';
                    String recommendation =
                        recommendationEntry['recommendation'] ??
                            'No recommendation available';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$reason: ${reasons[reason] ?? 0} times',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold, // Bold for reason
                          ),
                        ),
                        Text(
                          'Recommendation: $recommendation',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14, // Slightly smaller for recommendation
                          ),
                        ),
                        const SizedBox(height: 8), // Spacing between entries
                      ],
                    );
                  }).toList();

                  return Card(
                    color: const Color(0xFFBBDEFB),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${notificationDate.toString().split(' ')[0]}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Stimulants and influencers that affected your sleep quality with appropriate recommendations to ensure good sleep:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...reasonWidgets,
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
