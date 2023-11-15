// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:influ_app/screens/menuPage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../main.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_preferences.dart';

class PaymentPage extends StatefulWidget {
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isDeposit = true;
  bool isLoading = true;
  double amount = 500;
  Map<String, dynamic>? paymentIntent;
  late InAppWebViewController _webViewController;
  late WebViewController controller;
  bool shouldStopWebView = false;
  String url = "";
  void verifyPayment() async {
    print("Verify Payment ");
    var token =
        await PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
    //await AuthProvider.addTransaction(token: token, amount: amount);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MenuPage()),
    );
  }

  void getUrl() async {
    var token =
        await PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);

    var resp = await AuthProvider.encrypt(amount: amount, token: token);
    if (resp.success == "true") {
      setState(() {
        print("-------------- url is ${resp.data?["data"]["url"]}");
        url = resp.data?["data"]["url"];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('INFLU PAYMENT'),
        ),
        body: isLoading
            ? Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      // Customize the color of the indicator
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 17, 84, 167)),
                      // Customize the size of the indicator
                      strokeWidth: 5,
                    ),
                  ),
                ),
              )
            : InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(url)),
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var url = navigationAction.request.url;
                  print(
                      "-----------------------------------------url is ${url}");

                  if (url != null && url.toString().contains("sample")) {
                    print(
                        "--------------------------------------------------------------------${url.toString()}");
                    setState(() {
                      shouldStopWebView = true;
                    });
                    // _createOrder();

                    controller.stopLoading();
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  String content = "kalyan ";
                  if (url != null && url.toString().contains("/decrypt")) {
                    content = await _webViewController.evaluateJavascript(
                        source: 'document.body.innerText');
                    var jsonData = jsonDecode(content);

                    print(
                        "----------------------json data is ${jsonData["data"]}");
                    String responseString = jsonData["data"];
                    String orderStatusKey = "order_status=";
                    int orderStatusIndex =
                        responseString.indexOf(orderStatusKey);
                    if (orderStatusIndex != -1) {
                      int startIndex = orderStatusIndex + orderStatusKey.length;
                      int endIndex = responseString.indexOf("&", startIndex);
                      if (endIndex == -1) {
                        endIndex = responseString.length;
                      }

                      String orderStatusValue =
                          responseString.substring(startIndex, endIndex);
                      print("Order Status: $orderStatusValue");
                      if (orderStatusValue == 'Success') {
                        setState(() {
                          shouldStopWebView = true;
                        });
                        //_createOrder();

                        controller.stopLoading();
                        controller.clearCache();

                        verifyPayment();
                      } else {
                        setState(() {
                          shouldStopWebView = true;
                        });
                        //_createOrder();

                        controller.stopLoading();
                        controller.clearCache();
                        const snackBar = SnackBar(
                          content: Text(
                            'payment failed',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.pop(context);
                      }
                    } else {
                      setState(() {
                        shouldStopWebView = true;
                      });
                      //_createOrder();

                      controller.stopLoading();
                      const snackBar = SnackBar(
                        content: Text(
                          'error in payment',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MenuPage()),
                      );
                    }
                    setState(() {
                      shouldStopWebView = true;
                    });
                    //_createOrder();

                    controller.stopLoading();
                  }
                  if (shouldStopWebView) {
                    print("---------------------- content ${content}");
                    controller.stopLoading();
                  }
                },
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      mediaPlaybackRequiresUserGesture: false,
                      useShouldOverrideUrlLoading: true),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                androidOnPermissionRequest: (InAppWebViewController controller,
                    String origin, List<String> resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                }));
  }
}
