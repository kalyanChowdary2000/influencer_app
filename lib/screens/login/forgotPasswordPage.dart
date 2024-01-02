import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:influ_app/provider/AuthProvider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage();

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.text,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Mobile Number",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        // You can add more validation for phone numbers if needed
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Implement your "Forgot Password" logic here
                            // You can send a password reset link or a temporary password
                            // to the provided phone number and navigate the user to a confirmation page.
                            // For now, we'll just show a snackbar to simulate the process.
                            _onForgotPassword(phoneController.text);
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onForgotPassword(String phoneNumber) async {
    // Implement your "Forgot Password" logic here
    // For now, we'll just show a snackbar to simulate the process.
    await AuthProvider.forgotPassword(phone: phoneController.text);
    const snackBar = SnackBar(
      content: Text('Temporary password sent to your phone number.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.pop(context);
  }
}
