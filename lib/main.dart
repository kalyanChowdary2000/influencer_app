// ignore_for_file: prefer_const_constructors, unused_import, avoid_print, library_private_types_in_public_api, use_key_in_widget_constructors, unused_local_variable
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:influ_app/firebase_options.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:influ_app/screens/BottomBar/mainpage/catergories.dart';
import 'package:influ_app/screens/login/paymentPage.dart';
import 'package:influ_app/screens/login/register.dart';
import 'package:influ_app/screens/menuPage.dart';
import 'package:influ_app/utils/app_constants.dart';
import 'package:influ_app/utils/app_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceUtils.init();
  await AuthProvider.initalize();
  if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).whenComplete(() {
      print("Firebase Initialized");
    });
  } else {
    await Firebase.initializeApp(
      name: "beinfluencer",
      options: DefaultFirebaseOptions.currentPlatform,
    ).whenComplete(() {
      print("Firebase Initialized");
    });
  }

  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String data = "abc";
  ConnectivityResult _connectionStatus =
      ConnectivityResult.none; // You can initialize data here
  bool loginFlag = false;

  @override
  void initState() {
    super.initState();

    // Initialize connectivity listener
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result;
      });
      if (_connectionStatus == ConnectivityResult.none) {
        // No internet connection, show a dialog
        _showNoInternetDialog();
      } else {
        // _showNoInternetDialog();
      }
    });

    // You can perform any initialization here
    data = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    if (data != '') {
      loginFlag = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beinfluencer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Color.fromARGB(255, 65, 161, 236),
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 65, 161, 236),
        ),
      ),
      home: loginFlag ? MenuPage() : RegistrationPage(),
    );
  }
}

void _showNoInternetDialog() {
  Fluttertoast.showToast(
    msg: "No Internet Connection",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void configurePushNotification(userId) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  String? fcmToken;

  try {
    fcmToken = await FirebaseMessaging.instance.getToken();
    print('fcmToken $fcmToken');
  } catch (e) {
    print('fcmToken error ${e.toString()}');
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    print('fcmToken refreshed $fcmToken');
  }).onError((err) {
    // Error getting token.
  });
  FirebaseMessaging.instance.subscribeToTopic(userId);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    debugPrint(message.toString());
    print('Message data: ${message.data}');

    Map<String, dynamic> data = message.data;

    if (message.notification != null) {
      print(
        'Message also contained a notification: ${message.notification!.body ?? ''}',
      );
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("onMessageOpenedApp: ${message.data}");
  });

  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {}
}
