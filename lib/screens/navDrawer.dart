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
  String name = "kalyan";
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
      child: ListView(
        padding: EdgeInsets.all(1.0),
        children: <Widget>[
          DrawerHeader(
            child: Text(
              name,
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 224, 226, 224),
                image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: NetworkImage(
                        "${imageLink}?timestamp=${DateTime.now().millisecondsSinceEpoch}"))),
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            onTap: () => {
              // destroy(),
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {
              PreferenceUtils.clearAll(),
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistrationPage()),
              )
            },
          ),
        ],
      ),
    );
  }
}
