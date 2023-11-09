// ignore_for_file: prefer_const_constructors, sort_child_properties_last, library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, deprecated_member_use, unused_field, unused_local_variable, no_leading_underscores_for_local_identifiers, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:influ_app/screens/BottomBar/mainpage/catergories.dart';
import 'package:influ_app/screens/login/loginCategories.dart';
import 'package:influ_app/screens/menuPage.dart';
import 'package:influ_app/utils/app_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../../utils/app_constants.dart';
import 'loginPage.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

enum Gender { male, female, other }

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController =
      TextEditingController(); // New controller for DOB
  Gender _selectedGender = Gender.male;
  DateTime _selectedDate = DateTime.now(); // Selected DOB
  String termsAndConditionsUrl =
      'https://doc-hosting.flycricket.io/beinfluencer-terms-and-conditions/49735d97-d461-4185-9464-a386da4a7bc9/privacy';
  String privacyPolicyUrl =
      'https://doc-hosting.flycricket.io/beinfluencer-privacy-policy/8a598136-2ebc-408b-9083-6646e4a1bbc3/privacy';

  int _verificationCode = 0;
  bool _instagramFlag = false;
  bool _youtubeFlag = false;
  bool _isRegisterButtonEnabled = false;
  bool _isPasswordVisible = false;
  String _youtubeTittle = '';
  bool _isChecked = false;
  int _generateRandomCode() {
    final random = Random();
    return random.nextInt(900000) + 100000; // Generates a random 6-digit number
  }

  void _updateRegisterButtonState() {
    final instagramNotEmpty = _instagramController.text.isNotEmpty;
    final phoneNotEmpty = _phoneController.text.isNotEmpty;
    final emailNotEmpty = _emailController.text.isNotEmpty;
    final nameNotEmpty = _nameController.text.isNotEmpty;
    final passwordNotEmpty = _passwordController.text.isNotEmpty;
    final genderSelected = _selectedGender != null;
    final dobSelected = _selectedDate != null; // Check if DOB is selected

    setState(() {
      _isRegisterButtonEnabled = _instagramFlag ||
          _youtubeFlag &&
              phoneNotEmpty &&
              emailNotEmpty &&
              nameNotEmpty &&
              passwordNotEmpty &&
              genderSelected &&
              dobSelected; // A
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _register() async {
    String gender = '';
    if (_selectedGender == Gender.male) {
      gender = "male";
    } else {
      if (_selectedGender == Gender.female) {
        gender = "female";
      } else {
        gender = 'other';
      }
    }
    var response = await AuthProvider.signIn(
        dob: _dobController.text,
        gender: gender,
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        phone: _phoneController.text,
        instagram: _instagramController.text,
        youtube: _youtubeTittle);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginCategoriesPage()),
    );
  }

  void youtubeDialog() async {
    print("youtube dialog");
    _verificationCode = _generateRandomCode();
    bool _isVerified = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Verification Code'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Temporarily add this verification code to your youtube description',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$_verificationCode',
                            style: TextStyle(fontSize: 20)),
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: '$_verificationCode'));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Verification code copied to clipboard'),
                            ));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () => {Navigator.pop(context)},
                  child: Text('close'),
                  style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 65, 161, 236)),
                ),
                ElevatedButton(
                  onPressed: _isVerified
                      ? () {
                          Navigator.of(context).pop(); // Close the dialog
                        }
                      : () async {
                          var authResponse = await AuthProvider.verifyYoutbe(
                              channelLink: _youtubeController.text,
                              verificationCode: _verificationCode);
                          setState(() {
                            _isVerified = authResponse['success'];
                            _youtubeTittle = authResponse['channelId'];
                            print(_youtubeTittle);
                          });
                          if (_isVerified) {
                            _youtubeFlag = true;
                            _updateRegisterButtonState();
                            // Set the button to green with "Verified" text
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Account verified successfully'),
                            ));
                          } else {
                            // Show an error message
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Verification failed. Please try again.'),
                            ));
                          }
                        },
                  child: Text(_isVerified ? 'Verified' : 'Verify Account'),
                  style: ElevatedButton.styleFrom(
                    primary: _isVerified
                        ? Colors.green
                        : Color.fromARGB(255, 65, 161, 236),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void instagramDialog() async {
    print("instagram dialog");
    _verificationCode = _generateRandomCode();
    bool _isVerified = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Verification Code'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Temporarily add this verification code to your bio',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$_verificationCode',
                            style: TextStyle(fontSize: 20)),
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: '$_verificationCode'));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Verification code copied to clipboard'),
                            ));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () => {Navigator.pop(context)},
                  child: Text('close'),
                  style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 65, 161, 236)),
                ),
                ElevatedButton(
                  onPressed: _isVerified
                      ? () {
                          Navigator.of(context).pop(); // Close the dialog
                        }
                      : () async {
                          var authResponse = await AuthProvider.verifyInstagram(
                              username: _instagramController.text,
                              verificationCode: '${_verificationCode}');
                          setState(() {
                            _isVerified = authResponse['success'];
                          });
                          if (_isVerified) {
                            _instagramFlag = true;
                            _updateRegisterButtonState();
                            // Set the button to green with "Verified" text
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Account verified successfully'),
                            ));
                          } else {
                            // Show an error message
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Verification failed. Please try again.'),
                            ));
                          }
                        },
                  child: Text(_isVerified ? 'Verified' : 'Verify Account'),
                  style: ElevatedButton.styleFrom(
                    primary: _isVerified
                        ? Colors.green
                        : Color.fromARGB(255, 65, 161, 236),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void dispose() {
    super.dispose();
  }

  void checkLogin() async {
    var data = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    print('login data is ${data}');
    // await AuthProvider.verifyYoutbe(
    //     channelLink: "https://youtube.com/@jennierubyjane?si=WP_5v9S_29tLBwC0",
    //     verificationCode: "Sample");
    if (data != '') {
      //dispose();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primarySwatch: Colors.blue, // Set the primary color to pink
            hintColor: Color.fromARGB(255, 65, 161, 236),
          ),
          child: child ?? Container(),
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
        _updateRegisterButtonState(); // Update button state when DOB is selected
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 65, 161, 236),
        title: Text(
          'Registration Page',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 65, 161,
                            236)), // Set focused border color to pink
                  ),
                  labelStyle: TextStyle(
                    color:
                        Colors.black, // Set initial label text color to black
                  ),
                ),
                cursorColor: Color.fromARGB(
                    255, 65, 161, 236), // Set cursor color to pink
                maxLines: 1,
                onChanged: (_) => _updateRegisterButtonState(),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 65, 161,
                            236)), // Set focused border color to pink
                  ),
                  labelStyle: TextStyle(
                    color:
                        Colors.black, // Set initial label text color to black
                  ),
                ),
                cursorColor: Color.fromARGB(
                    255, 65, 161, 236), // Set cursor color to pink
                maxLines: 1,
                onChanged: (_) => _updateRegisterButtonState(),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 65, 161,
                            236)), // Set focused border color to pink
                  ),
                  labelStyle: TextStyle(
                    color:
                        Colors.black, // Set initial label text color to black
                  ),
                ),
                cursorColor: Color.fromARGB(
                    255, 65, 161, 236), // Set cursor color to pink
                maxLines: 1,
                onChanged: (_) => _updateRegisterButtonState(),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 65, 161,
                            236)), // Set focused border color to pink
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      color: Color.fromARGB(255, 65, 161, 236),
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  labelStyle: TextStyle(
                    color:
                        Colors.black, // Set initial label text color to black
                  ),
                ),
                cursorColor: Color.fromARGB(
                    255, 65, 161, 236), // Set cursor color to pink
                maxLines: 1,
                onChanged: (_) => _updateRegisterButtonState(),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 65, 161, 236)),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                cursorColor: Color.fromARGB(255, 65, 161, 236),
                maxLines: 1,
                readOnly: true, // Make the field read-only
                onTap: () {
                  _selectDate(context); // Open date picker on tap
                },
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _instagramController,
                      decoration: InputDecoration(
                        labelText: 'Instagram ID',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 65, 161, 236)),
                        ),
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      cursorColor: Color.fromARGB(255, 65, 161, 236),
                      maxLines: 1,
                      onChanged: (_) => _updateRegisterButtonState(),
                    ),
                  ),
                  SizedBox(
                      width:
                          10.0), // Add some spacing between the TextFormField and the button
                  ElevatedButton(
                    onPressed: () {
                      _instagramController.text.isNotEmpty
                          ? instagramDialog()
                          : null;
                    },
                    child: Text('verify Id'),
                    style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 65, 161, 236)),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _youtubeController,
                      decoration: InputDecoration(
                        labelText: 'Youtube Profile Link',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 65, 161, 236)),
                        ),
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      cursorColor: Color.fromARGB(255, 65, 161, 236),
                      maxLines: 1,
                      onChanged: (_) => _updateRegisterButtonState(),
                    ),
                  ),
                  SizedBox(
                      width:
                          10.0), // Add some spacing between the TextFormField and the button
                  ElevatedButton(
                    onPressed: () {
                      _youtubeController.text.isNotEmpty
                          ? youtubeDialog()
                          : null;
                    },
                    child: Text('verify Id'),
                    style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 65, 161, 236)),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('Gender', style: TextStyle(fontSize: 16)),
                  Radio(
                    value: Gender.male,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                        _updateRegisterButtonState();
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender = Gender.male;
                        _updateRegisterButtonState();
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.male,
                          size: 30.0,
                          color: _selectedGender == Gender.male
                              ? Color.fromARGB(255, 65, 161, 236)
                              : Colors.grey,
                        ),
                        Text(
                          'Male',
                          style: TextStyle(
                            color: _selectedGender == Gender.male
                                ? Color.fromARGB(255, 65, 161, 236)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio(
                    value: Gender.female,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                        _updateRegisterButtonState();
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender = Gender.female;
                        _updateRegisterButtonState();
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.female,
                          size: 30.0,
                          color: _selectedGender == Gender.female
                              ? Color.fromARGB(255, 65, 161, 236)
                              : Colors.grey,
                        ),
                        Text(
                          'Female',
                          style: TextStyle(
                            color: _selectedGender == Gender.female
                                ? Color.fromARGB(255, 65, 161, 236)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio(
                    value: Gender.other,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                        _updateRegisterButtonState();
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender = Gender.other;
                        _updateRegisterButtonState();
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.transgender,
                          size: 30.0,
                          color: _selectedGender == Gender.other
                              ? Color.fromARGB(255, 65, 161, 236)
                              : Colors.grey,
                        ),
                        Text(
                          'Other',
                          style: TextStyle(
                            color: _selectedGender == Gender.other
                                ? Color.fromARGB(255, 65, 161, 236)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                    Text("I have read and agree to the "),
                    GestureDetector(
                      onTap: () async =>
                          await launchUrl(Uri.parse(termsAndConditionsUrl)),
                      child: Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          color: Color.fromARGB(255, 65, 161, 236),
                        ),
                      ),
                    ),
                    Text(" and "),
                    GestureDetector(
                      onTap: () async =>
                          await launchUrl(Uri.parse(privacyPolicyUrl)),
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                          color: Color.fromARGB(255, 65, 161, 236),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isRegisterButtonEnabled ? _register : null,
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  primary: _isRegisterButtonEnabled
                      ? Color.fromARGB(255, 65, 161, 236)
                      : Colors.grey,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already a user --->>"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context_) {
                            return LoginPage();
                          },
                        ),
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Color.fromARGB(255, 65, 161, 236),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
