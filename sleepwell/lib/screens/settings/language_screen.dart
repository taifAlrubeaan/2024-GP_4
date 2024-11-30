import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widget/choice_chip_widget.dart';

import '../../locale/app_translation.dart';
import '../../locale/local_controller.dart';

class LangageScreen extends StatelessWidget {
  const LangageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 50,
        title: Text(
          'Language'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        // backgroundColor: Color.fromRGBO(255, 130, 68, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded), // Home icon
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ElevatedButton(
            //   onPressed: () {
            //     localController.changeLanguage('ar');
            //     showAwesomeDialog(
            //       "Successful",
            //       "Change App Language to Arabic successflly".tr,
            //       dialogType: DialogType.success,
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     minimumSize: const Size(150, 50),
            //     backgroundColor: const Color(0xfffcab83),
            //     foregroundColor: Colors.black87,
            //   ),
            //   child: Text(
            //     'Arabic'.tr,
            //     style: const TextStyle(color: Colors.black, fontSize: 16),
            //   ),
            // ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     localController.changeLanguage('ar');
            //     showAwesomeDialog(
            //       "Successful",
            //       "Change App Language to English successflly".tr,
            //       dialogType: DialogType.success,
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     minimumSize: const Size(150, 50),
            //     backgroundColor: const Color(0xfffcab83),
            //     foregroundColor: Colors.black87,
            //   ),
            //   child: Text(
            //     'English'.tr,
            //     style: TextStyle(color: Colors.black, fontSize: 16),
            //   ),
            // ),
            SizedBox(
              height: 115,
              child: ChoiceChipWidget(
                choices: ["Arabic".tr, "English".tr],
                initialSelected: Get.locale?.languageCode == 'en' ? 1 : 0,
                buttonSize: const Size(100, 30),
                unselectedColor: const Color(0xfffcab83),
                selectedColor: const Color(0xfffcab83),
                // labelColor: Colors.black,
                changeSelected: (selectedValue) {
                  print(":::::::::::::::::::::$selectedValue");
                  // final LocaleThemeController localeController = Get.find();
                  final AppLocalelcontroller localeController = Get.find();

                  if (selectedValue == 0) {
                    localeController.changeLanguage('ar');
                  } else if (selectedValue == 1) {
                    localeController.changeLanguage('en');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
