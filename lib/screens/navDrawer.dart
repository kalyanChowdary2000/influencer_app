// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:influ_app/screens/drawer/profilePage.dart';
import 'package:influ_app/screens/drawer/settingPage.dart';
import 'package:influ_app/screens/login/register.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_constants.dart';
import '../utils/app_preferences.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String name = "";
  var imageLink = '';
  bool verifiedFlag = false;

  String instagramUrl =
      'https://www.instagram.com/beinfluencer.in?igsh=Y3lrZTN6ajd0djU=';
  String snapchatUrl =
      'https://www.snapchat.com/add/beinfluencer.in?share_id=RrlNkI7NjsA&locale=en-US';
  String threadsUrl = 'https://www.threads.net/@beinfluencer.in';
  String twitterUrl =
      'https://x.com/beinfluencer_in?s=11&t=LE_GCN0kP-z10qOulQh_-g';
  void fetchData() async {
    var data = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    if (data != '') {
      var userData = json.decode(data);
      if (userData['active']) {
        setState(() {
          verifiedFlag = true;
        });
      }
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

  Widget buildSocialMediaIcon(String imageUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        width: 35,
        child: Image.network(imageUrl),
      ),
    );
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
                      color: const Color.fromARGB(255, 15, 15, 15),
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.verified_user,
              color: verifiedFlag ? Colors.blue : null,
            ),
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
          Spacer(),

          // Social media icons row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildSocialMediaIcon(
                  "https://azhanaresources.s3.ap-south-1.amazonaws.com/images/instagram.png",
                  () async {
                    await launchUrl(Uri.parse(instagramUrl));
                    // Handle Instagram tap
                  },
                ),
                buildSocialMediaIcon(
                  "https://azhanaresources.s3.ap-south-1.amazonaws.com/images/snapchat.png",
                  () async {
                    await launchUrl(Uri.parse(snapchatUrl));
                    // Handle Snapchat tap
                  },
                ),
                buildSocialMediaIcon(
                  "https://azhanaresources.s3.ap-south-1.amazonaws.com/images/threads.png",
                  () async {
                    await launchUrl(Uri.parse(threadsUrl));
                    // Handle Snapchat tap
                  },
                ),
                buildSocialMediaIcon(
                  "https://azhanaresources.s3.ap-south-1.amazonaws.com/images/twitter.png",
                  () async {
                    await launchUrl(Uri.parse(twitterUrl));
                    // Handle Snapchat tap
                  },
                ),
                // Add more social media icons as needed
              ],
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
