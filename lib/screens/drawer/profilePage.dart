// ignore_for_file: prefer_final_fields, prefer_const_constructors, unused_local_variable, depend_on_referenced_packages, unused_import, use_build_context_synchronously, avoid_print, sort_child_properties_last
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:influ_app/screens/drawer/changePassword.dart';
import 'package:influ_app/screens/login/register.dart';
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
  TextEditingController _accountHolderNameController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _branchController = TextEditingController();
  TextEditingController _bankNameController = TextEditingController();
  TextEditingController _ifscCodeController = TextEditingController();

  bool _isEditing = false;
  void fetchYoutubeData() async {
    var data = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    print('login data is ${data}');

    var youtubeData = await AuthProvider.fetchYoutube();
    print(youtubeData);
    print(youtubeData["data"]["_id"]);
    setState(() {
      int? fc = int.tryParse(youtubeData["data"]["followerCount"]);
      _youtubeController.text = youtubeData["data"]["customUrl"];
    });
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _deleteUser() async {
    bool res = await AuthProvider.deleteUser(phone: _numberController.text);
    if (res) {
      // Navigator.of(context).popUntil((route) => route.)
      // await PreferenceUtils.setInt(
      //     AppPreferenceConstants.LOGIN_TIME, 1627376688);

      PreferenceUtils.clearAll();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegistrationPage()),
      );
    } else {
      const snackBar = SnackBar(
        content: Text('Error:try restarting app'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    // Implement the logic to delete the user account here.
    // You may show a confirmation dialog before proceeding with the deletion.
  }

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

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // phoneController.text = _mobileNumber;
      // emailController.text = _email;
      // nameController.text = _firstName;
      // stateController.text = _state;
      // cityController.text = _city;
      // pincodeController.text = _pincode;
    });
  }

  void _saveProfile() async {
    setState(() {
      _isEditing = false;
    });
    await AuthProvider.editUser(updatedData: {
      "accountHolderName": _accountHolderNameController.text,
      "accountNumber": _accountNumberController.text,
      "bankName": _bankNameController.text,
      "branch": _branchController.text,
      "email": _emailController.text,
      "ifscCode": _ifscCodeController.text,
      "name": _nameController.text,
    }, phone: _numberController.text);
    loadProfile(); // isLoginCheck();
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
        // _youtubeController.text = userData["youtube"];
        _numberController.text = userData["_id"];
        _dobController.text = userData["dob"];
        _genderController.text = userData["gender"];
        _accountNumberController.text = userData?["accountNumber"] ?? '';
        _ifscCodeController.text = userData?["ifscCode"] ?? '';
        _branchController.text = userData?["branch"] ?? '';
        _bankNameController.text = userData?["bankName"] ?? '';
        _accountHolderNameController.text =
            userData?["accountHolderName"] ?? '';
        // _youtubeController.text = userData["youtube"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
    fetchYoutubeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 56, 164, 222),
        title: Text('Profile Page'),
        // actions: [
        //   if (!_isEditing)
        //     IconButton(
        //       icon: Icon(Icons.edit),
        //       onPressed: () {
        //         setState(() {
        //           _isEditing = true;
        //         });
        //       },
        //     ),
        //   if (_isEditing)
        //     IconButton(
        //       icon: Icon(Icons.save),
        //       onPressed: _saveProfile,
        //     ),
        // ],
      ),
      body: Center(
        child: SingleChildScrollView(
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
                        enabled: false,
                        keyboardType: TextInputType.number,
                        controller: _numberController,
                        decoration: InputDecoration(
                          labelText: "Number",
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                          enabled: false,
                          controller: _instagramController,
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
                        "Youtube",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                          enabled: false,
                          controller: _youtubeController,
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
                        "Account Holder Name",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                          enabled: _isEditing,
                          controller: _accountHolderNameController,
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
                        "Bank Name",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                          enabled: _isEditing,
                          controller: _bankNameController,
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
                        "Account Number",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                          enabled: _isEditing,
                          controller: _accountNumberController,
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
                        "Ifsc Code",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                          enabled: _isEditing,
                          controller: _ifscCodeController,
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
                        "Branch Name",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                          enabled: _isEditing,
                          controller: _branchController,
                          decoration: InputDecoration()),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.0),
              _isEditing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _saveProfile,
                          child: Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: _cancelEditing,
                          child: Text('Cancel'),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _startEditing,
                      child: Text('Edit'),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePasswordPage()),
                      )
                    }, //_isEditing ? null : _navigateToChangePassword,
                    child: Text('Change Password'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteUser,
                    child: Text('Delete User'),
                    style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 235, 101, 92)),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
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
      ),
    );
  }
}
