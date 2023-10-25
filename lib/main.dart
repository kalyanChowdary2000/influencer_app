// ignore_for_file: prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:influ_app/screens/BottomBar/mainpage/catergories.dart';
import 'package:influ_app/screens/login/register.dart';
import 'package:influ_app/screens/menuPage.dart';
import 'package:influ_app/utils/app_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PreferenceUtils.init();
  AuthProvider.initalize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INFLU APP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.purple,
        hintColor: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink,
        ),
      ),
      home: RegistrationPage(),
    );
  }
}
