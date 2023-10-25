// ignore_for_file: prefer_final_fields, prefer_const_constructors, unused_local_variable, depend_on_referenced_packages, unused_import

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:influ_app/utils/app_preferences.dart';

import '../../utils/app_constants.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User's YouTube ID
  File? _userImage; // User's profile image file
  ImageProvider<Object>? _imageProvider;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _instagramController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _youtubeController = TextEditingController();

  bool _isEditing = false;

  // Function to open an image picker for editing the profile image
  Future<void> _editProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _userImage = File(pickedFile.path);
      });
      print(pickedFile.path);
      // Convert the image to base64
      List<int> imageBytes = await pickedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      //print(base64Image);
      setState(() {
        _imageProvider = FileImage(_userImage!);
      });
      await AuthProvider.storeProfile(
          imageData: imageBytes, id: _numberController.text);
    }
  }

  void _saveProfile() {
    setState(() {
      _isEditing = false;
    });
  }

  void _selectGender() async {
    final selectedGender = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Gender'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.male),
              onPressed: () {
                Navigator.of(context).pop('Male');
              },
            ),
            IconButton(
              icon: Icon(Icons.female),
              onPressed: () {
                Navigator.of(context).pop('Female');
              },
            ),
          ],
        );
      },
    );

    if (selectedGender != null) {
      setState(() {
        _genderController.text = selectedGender;
      });
    }
  }

  void loadProfile() async {
    var data =
        await PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    if (data != '') {
      var userData = json.decode(data);

      setState(() {
        _imageProvider = NetworkImage(
            "${userData['imageLink']}?timestamp=${DateTime.now().millisecondsSinceEpoch}");
        print(_imageProvider);
        //       print(_userImage);
        _nameController.text = userData["name"];
        _emailController.text = userData["email"];
        _instagramController.text = userData["instagram"];
        _numberController.text = userData["_id"];
        _dobController.text = userData["dob"];
        _genderController.text = userData["gender"];
        // _youtubeController.text = userData["youtube"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Profile Page'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),

            GestureDetector(
              onTap: _isEditing ? _editProfileImage : null,
              child: CircleAvatar(
                radius: 75.0,
                backgroundImage: _imageProvider,
                // Show an icon if _userImage is null
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 20.0),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Name",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                        enabled: _isEditing,
                        controller: _nameController,
                        decoration: InputDecoration()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 20.0),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Number",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                        enabled: _isEditing,
                        controller: _numberController,
                        decoration: InputDecoration()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 20.0),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Email",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                        enabled: _isEditing,
                        controller: _emailController,
                        decoration: InputDecoration()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 20.0),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Date of Birth",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      enabled: _isEditing,
                      controller: _dobController,
                      decoration: InputDecoration(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 20.0),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Gender",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      enabled: _isEditing, // Disable text field for gender
                      controller: _genderController,
                      decoration: InputDecoration(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 20.0),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Instagram",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                        enabled: _isEditing,
                        controller: _instagramController,
                        decoration: InputDecoration()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8.0),
            //   child: Row(
            //     children: [
            //       SizedBox(width: 20.0),
            //       Expanded(
            //         flex: 2,
            //         child: Text(
            //           "Youtube",
            //           style: TextStyle(
            //               color: Colors.black, fontWeight: FontWeight.bold),
            //         ),
            //       ),
            //       Expanded(
            //         flex: 5,
            //         child: TextFormField(
            //             enabled: _isEditing,
            //             controller: _youtubeController,
            //             decoration: InputDecoration()),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
