import 'package:get/get.dart';

import 'onboardingInfo.dart';

class OnboardingData {
  List<OnboardingInfo> items = [
    OnboardingInfo(
        title: "Smart sleep planner".tr,
        descriptions:
            "Wake up refreshed with optimized wake-up times based on your sleep cycles. Say goodbye to tired mornings."
                .tr,
        image: "assets/sleepicon.png"),
    OnboardingInfo(
        title: "flexible alarm".tr,
        descriptions:
            "Customize your wake-up with the various alarm options to providing a tailored and enjoyable wake-up feature"
                .tr,
        image: "assets/alarmicon2.png"),
    OnboardingInfo(
        title: "enhance your kid's sleep".tr,
        descriptions:
            "Track and monitor your family's sleep patterns! Add your kids as beneficiaries to ensure they get the rest they need."
                .tr,
        image: "assets/USERICON.png"),
  ];
}
