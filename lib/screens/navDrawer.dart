// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:influ_app/screens/drawer/profilePage.dart';
import 'package:influ_app/screens/drawer/settingPage.dart';
import 'package:influ_app/screens/login/register.dart';
import '../utils/app_constants.dart';
import '../utils/app_preferences.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String name = "";
  var imageLink = '';
  void fetchData() async {
    var data =
        await PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    if (data != '') {
      var userData = json.decode(data);

      print(userData);
      setState(() {
        imageLink = userData['imageLink'];
        name = userData["name"];
      });
    }
  }

  @override
  void destroy() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 500, // Set the desired height
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 224, 226, 224),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    "${imageLink}?timestamp=${DateTime.now().millisecondsSinceEpoch}"),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(
                //   width: 10,
                // ),
                Text(
                  "   $name",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              PreferenceUtils.clearAll();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistrationPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
