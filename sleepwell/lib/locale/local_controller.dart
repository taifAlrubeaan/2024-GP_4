import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../main.dart';

class AppLocalelcontroller extends GetxController {
  late Locale language;

  @override
  void onInit() {
    super.onInit();
    language = const Locale('en');
    String langCode = getUserLangageFromCashe();
    language = langCode == 'sys'
        ? Get.deviceLocale ?? const Locale('ar')
        : Locale(langCode);
  }

  void changeLanguage(String langCode) {
    print(":::::::::::Change language to :$langCode");
    language = langCode == 'sys'
        ? Get.deviceLocale ?? const Locale('ar')
        : Locale(langCode);

    // SettingsBox.setLanguage(langCode)
    saveUserLangageToCashe(langCode);
    Get.updateLocale(language);
  }

  void saveUserLangageToCashe(String lang) {
    prefs.setString('userLanguage', lang);
  }

  String getUserLangageFromCashe() {
    return prefs.getString('userLanguage') ?? 'sys';
  }
}
