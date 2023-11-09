// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String termsAndConditionsUrl =
      'https://doc-hosting.flycricket.io/beinfluencer-terms-and-conditions/49735d97-d461-4185-9464-a386da4a7bc9/privacy';
  String privacyPolicyUrl =
      'https://doc-hosting.flycricket.io/beinfluencer-privacy-policy/8a598136-2ebc-408b-9083-6646e4a1bbc3/privacy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.8, // Set to 80% of the screen width
                child: ElevatedButton(
                  onPressed: () async {
                    print("privacy policy");
                    await launchUrl(Uri.parse(privacyPolicyUrl));
                  },
                  child: Text("Privacy Policy"),
                ),
              ),
            ),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.8, // Set to 80% of the screen width
                child: ElevatedButton(
                  onPressed: () async {
                    print("privacy policy");
                    await launchUrl(Uri.parse(privacyPolicyUrl));
                  },
                  child: Text("Terms & Conditions"),
                ),
              ),
            ),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: ElevatedButton(
                  onPressed: () async {
                    print("contact us");
                    var contactUsEmail = "contact@beinfluencer.in";
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: contactUsEmail,
                    );
                    await launch(emailLaunchUri.toString());
                  },
                  child: Text("Contact Us (Email)"),
                ),
              ),
            ),
          ],
        ));
  }
}
