// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:audioplayers_web/audioplayers_web.dart';
import 'package:awesome_notifications/awesome_notifications_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:connectivity_plus/src/connectivity_plus_web.dart';
import 'package:firebase_analytics_web/firebase_analytics_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_database_web/firebase_database_web.dart';
import 'package:firebase_messaging_web/firebase_messaging_web.dart';
import 'package:flutter_native_splash/flutter_native_splash_web.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:permission_handler_html/permission_handler_html.dart';
import 'package:rive_common/rive_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  AudioplayersPlugin.registerWith(registrar);
  AwesomeNotificationsWeb.registerWith(registrar);
  FirebaseFirestoreWeb.registerWith(registrar);
  ConnectivityPlusWebPlugin.registerWith(registrar);
  FirebaseAnalyticsWeb.registerWith(registrar);
  FirebaseAuthWeb.registerWith(registrar);
  FirebaseCoreWeb.registerWith(registrar);
  FirebaseDatabaseWeb.registerWith(registrar);
  FirebaseMessagingWeb.registerWith(registrar);
  FlutterNativeSplashWeb.registerWith(registrar);
  GoogleSignInPlugin.registerWith(registrar);
  WebPermissionHandler.registerWith(registrar);
  RivePlugin.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
