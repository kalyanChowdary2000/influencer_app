// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:influ_app/provider/AuthProvider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage();

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late AuthProvider _authProvider;
  final _formKey = GlobalKey<FormState>();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Current Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  // Implement additional password validation if needed
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  } else if (value.length < 6) {
                    return 'Password length must be 6 or more';
                  }
                  // Implement additional password validation if needed
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changePassword() async {
    print("------------>>> in change password");
    if (_formKey.currentState!.validate()) {
      String currentPassword = currentPasswordController.text;
      String newPassword = newPasswordController.text;
      var response = await AuthProvider.changePassword(
          newPassword: newPassword, password: currentPassword);
      // Implement your password change logic here
      // For now, we'll just show a snackbar to simulate the process.
      if (response) {
        const snackBar = SnackBar(
          content: Text('Password changed successfully.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context);
      } else {
        const snackBar = SnackBar(
          content: Text('password not matching'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
