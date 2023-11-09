// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, prefer_final_fields, avoid_unnecessary_containers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:influ_app/main.dart';
import 'package:influ_app/screens/BottomBar/completed/completed.dart';
import 'package:influ_app/screens/BottomBar/mainpage/mainPage.dart';
import 'package:influ_app/screens/BottomBar/newEnquiry.dart';
import 'package:influ_app/screens/BottomBar/upComing.dart';
import 'package:influ_app/utils/app_constants.dart';
import 'package:influ_app/utils/app_preferences.dart';

import './navDrawer.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    MainPage(),
    NewEnquiryPage(),
    // UpcomingPage(),
    CompletedPage(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void initFirebase() async {
    var data =
        await PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    if (data != '') {
      var userData = json.decode(data);
      configurePushNotification(userData["_id"]);
    }
  }

  @override
  void initState() {
    super.initState();
    initFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 65, 161, 236),
        title: Row(
          children: [
            Image.network(
              'https://azhanaresources.s3.ap-south-1.amazonaws.com/images/logo.jpg', // Replace with your logo image path
              height: 35, // Adjust the height as needed
              width: 35, // Adjust the width as needed
            ),
            SizedBox(width: 8), // Add spacing between the logo and text
            Text(
              'Beinfluencer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: Container(
          child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //backgroundColor: Colors.yellow,
        selectedItemColor: Color.fromARGB(255, 65, 161, 236),
        unselectedItemColor: Color.fromARGB(255, 12, 12, 12),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_sharp),
            label: 'Live Adds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all),
            label: 'Completed',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      )),
    );
  }
}
