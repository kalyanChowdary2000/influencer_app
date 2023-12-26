// ignore_for_file: avoid_print, prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import, dead_code, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:influ_app/screens/BottomBar/mainpage/mainPage.dart';
import 'package:influ_app/screens/login/forgotPasswordPage.dart';
import 'package:influ_app/screens/login/loginCategories.dart';
import 'package:influ_app/screens/menuPage.dart';
import '../../main.dart';
import '../../provider/AuthProvider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;

  PageController? _pageController;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30.0);
    return Scaffold(
        appBar: AppBar(
          title: Text("Login", style: TextStyle(fontSize: 25)),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
                        cursorColor: Color.fromARGB(255, 65, 161, 236),
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        //inputFormatters: [FilteringTextInputFormatter.allow()],

                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 65, 161,
                                    236)), // Set focused border color to pink
                          ),
                          labelStyle: TextStyle(
                            color: Colors
                                .black, // Set initial label text color to black
                          ),
                          fillColor: Color.fromARGB(255, 65, 161, 236),
                          iconColor: Color.fromARGB(255, 65, 161, 236),
                          labelText: "Mobile Number",
                          border: OutlineInputBorder(
                              borderRadius: borderRadius,
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 65, 161, 236))),
                          prefixIcon: Icon(Icons.phone,
                              color: Color.fromARGB(255, 65, 161, 236)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: !_passwordVisible,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 65, 161,
                                    236)), // Set focused border color to pink
                          ),
                          labelStyle: TextStyle(
                            color: Colors
                                .black, // Set initial label text color to black
                          ),
                          border: OutlineInputBorder(
                            borderRadius: borderRadius,
                          ),
                          prefixIcon: Icon(Icons.lock,
                              color: Color.fromARGB(255, 65, 161, 236)),
                          labelText: "Password",
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,

                              color: Color.fromARGB(255, 65, 161, 236),
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 4) {
                            return 'Password length must be 4 or more';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 1.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context_) {
                                return ForgotPasswordPage(); //ForgotPasswordPage();
                              },
                            ),
                          );
                          // Navigate to the Forgot Password page
                          // Implement your Forgot Password logic here
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16.0),
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 65, 161, 236)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              debugPrint(phoneController.text);
                              debugPrint(passwordController.text);
                              // Navigate the user to the Home page
                              _onLogin(
                                phone: phoneController.text,
                                password: passwordController.text,
                              );
                            }
                          },
                          child: const Text('Login'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Future<void> _onLogin({
    required String phone,
    required String password,
  }) async {
    var resp = await AuthProvider.login(phone: phone, password: password);
    print("------------${resp}");
    if (resp["success"]) {
      dispose();
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context_) {
          return MenuPage();
        },
      ));
    } else {
      const snackBar = SnackBar(
        content:
            Text('Login failed! Please check your credentials and try again!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    // _authProvider
    //     .login(phone: phone, password: password)
    //     .then((bool isLoginSuccess) async {
    //   if (isLoginSuccess) {
    //     await context.read<NatsProvider>().retryConnection();
    //     await context.read<ProductProvider>().fetchAllProducts();
    //     await context.read<AuthProvider>().fetchSuperVendors();
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context_) {
    //           return HomePage(
    //             currentIndex: 0,
    //           );
    //         },
    //       ),
    //     );
    //   } else {
    //     const snackBar = SnackBar(
    //       content: Text(
    //           'Login failed! Please check your credentials and try again!'),
    //     );
    //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //   }
    // });
  }
}
