// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, prefer_final_fields, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:influ_app/screens/BottomBar/completed/completed.dart';
import 'package:influ_app/screens/BottomBar/mainpage/mainPage.dart';
import 'package:influ_app/screens/BottomBar/newEnquiry.dart';
import 'package:influ_app/screens/BottomBar/upComing.dart';

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
    UpcomingPage(),
    CompletedPage(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text('INFLU APP'),
        backgroundColor: Color.fromARGB(255, 43, 32, 99),
      ),
      body: Center(
        child: _widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: Container(
          child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //backgroundColor: Colors.yellow,
        selectedItemColor: Color.fromARGB(255, 43, 32, 99),
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
