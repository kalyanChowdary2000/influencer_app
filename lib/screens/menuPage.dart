// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, prefer_final_fields, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:influ_app/main.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:influ_app/screens/BottomBar/completed/completed.dart';
import 'package:influ_app/screens/BottomBar/mainpage/mainPage.dart';
import 'package:influ_app/screens/BottomBar/newEnquiry.dart';
import 'package:influ_app/screens/BottomBar/upComing.dart';
import 'package:influ_app/screens/BottomBar/walletPage.dart';
import 'package:influ_app/utils/app_constants.dart';
import 'package:influ_app/utils/app_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import './navDrawer.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  int selectedIndex = 0;
  var walletAmount = 0;

  late AnimationController _rotationController;
  bool isRotating = false;
  late List<Widget> _widgetOptions;
  // static List<Widget> _widgetOptions = <Widget>[
  //   MainPage(paymentFlag: paymentFlag),
  //   NewEnquiryPage(),
  //   CompletedPage(),
  // ];
  void getLocation() async {
    var status = await Permission.location.status;
    print(
        "______________________________________location status----------${status}");
    if (status != PermissionStatus.granted) {
      await Permission.location.request();
      var status1 = await Permission.location.status;
      if (status == PermissionStatus.granted) {
        getLocation();
      }
    } else {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placemarks[0];

        print(
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}');
        print('Address: $place');
        var data = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
        if (data != '') {
          var token =
              PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
          var userData = json.decode(data);
          await AuthProvider.editUser(updatedData: {
            "address": {"address": place, "coordiantes": position}
          }, phone: userData["_id"]);
        }
      } catch (e) {
        print('Error getting location: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initFirebase();
    refreshWallet();
    getLocation();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // When the rotation animation completes, reset the rotation
          _rotationController.reset();
          setState(() {
            isRotating = false;
          });
        }
      });
    _widgetOptions = <Widget>[
      MainPage(),
      NewEnquiryPage(),
      CompletedPage(),
    ];
  }

  void _startRotation() {
    if (!isRotating) {
      _rotationController.forward();
      setState(() {
        isRotating = true;
      });
    }
  }

  void _onItemTapped(int index) {
    refreshWallet();
    setState(() {
      selectedIndex = index;
    });
  }

  void refreshWallet() async {
    try {
      var data =
          await PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
      if (data != '') {
        var token =
            await PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
        await AuthProvider.fetchWallet(token: token);
        var userData = json.decode(data);
        setState(() {
          print(
              "================================================================wallet money is ${userData["walletMoney"]}");
          walletAmount =
              userData["walletMoney"] != null ? userData["walletMoney"] : 0;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void initFirebase() async {
    var data =
        await PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    if (data != '') {
      var userData = json.decode(data);
      setState(() {
        walletAmount = userData["walletMoney"] ? userData["walletMoney"] : 0;
      });
      configurePushNotification(userData["_id"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: NavDrawer(),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 65, 161, 236),
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.network(
                      'https://azhanaresources.s3.ap-south-1.amazonaws.com/images/logo.jpg',
                      height: 35,
                      width: 35,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Beinfluencer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WalletPage()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 236, 119,
                              9), // Customize the background color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet, // Wallet symbol
                          color: Color.fromARGB(255, 237, 234,
                              234), // Customize the color as needed
                        ),
                      ),
                    ),
                    // AnimatedBuilder(
                    //   animation: _rotationController,
                    //   builder: (context, child) {
                    //     return Transform.rotate(
                    //       angle: _rotationController.value * 2 * pi,
                    //       child: GestureDetector(
                    //         onTap: () {
                    //           refreshWallet();
                    //           _startRotation();
                    //         },
                    //         child: Icon(
                    //           Icons.refresh, // Refresh symbol
                    //           color:
                    //               Colors.white, // Customize the color as needed
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: _widgetOptions.elementAt(selectedIndex),
        ),
        bottomNavigationBar: Container(
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color.fromARGB(255, 65, 161, 236),
            unselectedItemColor: Color.fromARGB(255, 12, 12, 12),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.question_answer_sharp),
                label: 'Live Ads',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.done_all),
                label: 'Completed',
              ),
            ],
            currentIndex: selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
