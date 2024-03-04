// ignore_for_file: prefer_typing_uninitialized_variables, unused_import, unnecessary_brace_in_string_interps, await_only_futures, avoid_print, library_prefixes

import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encryptText;
import 'package:dio/dio.dart';
import '../utils/app_constants.dart';
import '../utils/app_network_constants.dart';
import '../utils/app_preferences.dart';

class CustomResponse {
  String success;
  Map<String, dynamic>? data;

  CustomResponse({required this.success, this.data});
}

class AuthProvider {
  static var dio;
  static initalize() {
    dio = Dio();
    debugPrint("Initialized auth provider");
  }

  static Future<bool> changePassword({
    required String password,
    required String newPassword,
  }) async {
    try {
      String token =
          PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {
        "token": token,
        "password": password,
        "newPassword": newPassword
      };
      Response response = await dio.post(
        AppNetworkConstants.apiChangePassword,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      print("-----------------chnage password status ${data}");
      //final data = jsonDecode(response.data);
      return data["success"];
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Map<String, dynamic> decrypt(inputString) {
    final key = encryptText.Key.fromBase64(
        "/tck8EIqBYxdrf1yPgMt9aA9/28ZI/g83KnLpWt1ojo="); // Replace with your actual 32-byte key
    final iv = IV.fromBase64(
        "/tck8EIqBYxdrf1yPgMt9Q=="); // Replace with the IV generated in Node.js

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encryptedText = Encrypted.fromBase64(
        inputString); // Replace with the encrypted data generated in Node.js

    final String decryptedText = encrypter.decrypt(encryptedText, iv: iv);
    print("------------decrypted data is ${decryptedText}");
    return json.decode(decryptedText);
  }

  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String gender,
    required String dob,
    String? instagram,
    String? youtube,
  }) async {
    try {
      var params = {
        "email": email,
        "password": password,
        "name": name,
        "phone": phone,
        "instagram": instagram,
        "youtube": youtube,
        "gender": gender,
        "dob": dob
      };
      Response response = await dio.post(
        AppNetworkConstants.apiSignin,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      //final data = jsonDecode(response.data);
      bool isLoginSuccess = data["success"];
      print("response from server is ${isLoginSuccess}  ${data["data"]}");
      if (isLoginSuccess) {
        await PreferenceUtils.setString(
          AppPreferenceConstants.LOGIN_KEY,
          json.encode(data["data"]),
        );
        await PreferenceUtils.setString(
          AppPreferenceConstants.TOKEN_KEY,
          data["token"],
        );
        return {
          "success": true,
        };
      }
      return {
        "success": false,
      };
      // ToDo : connect to nats
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<bool> forgotPassword({
    required String phone,
  }) async {
    try {
      var params = {
        "_id": phone,
      };
      Response response = await dio.post(
        AppNetworkConstants.apiForgotPassword,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<Map<String, dynamic>> login({
    required String password,
    required String phone,
  }) async {
    try {
      var params = {
        "password": password,
        "phone": phone,
      };
      print(params);
      Response response = await dio.post(
        AppNetworkConstants.apiLogin,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      //final data = jsonDecode(response.data);
      bool isLoginSuccess = data["success"];
      print("response from server is ${isLoginSuccess}  ${data["data"]}");
      if (isLoginSuccess) {
        await PreferenceUtils.setString(
          AppPreferenceConstants.LOGIN_KEY,
          json.encode(data["data"]),
        );
        await PreferenceUtils.setString(
          AppPreferenceConstants.TOKEN_KEY,
          data["token"],
        );
        return {
          "success": true,
        };
      }
      return {
        "success": false,
      };
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<bool> deleteUser({
    required String phone,
  }) async {
    try {
      var token = PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {"_id": phone, "token": token};
      print(params);
      Response response = await dio.post(
        AppNetworkConstants.apiDeleteUser,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      //final data = jsonDecode(response.data);
      bool isLoginSuccess = data["success"];
      print("response from server is ${isLoginSuccess}  ${data["data"]}");
      if (isLoginSuccess) {
        return true;
      }
      return false;
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<Map<String, dynamic>> verifyInstagram(
      {required String username, required String verificationCode}) async {
    try {
      var params = {"username": username, "verificationCode": verificationCode};
      Response response = await dio.post(
        AppNetworkConstants.apiVerifyInstagram,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      return data;
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<Map<String, dynamic>> verifyYoutbe(
      {required String channelLink, required verificationCode}) async {
    try {
      var params = {
        "channelLink": channelLink,
        "verificationCode": verificationCode
      };
      Response response = await dio.post(
        AppNetworkConstants.apiVerifyYoutube,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      return data;
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<Map<String, dynamic>> fetchInstagram() async {
    try {
      var token = PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {"token": token};
      Response response = await dio.post(
        AppNetworkConstants.apiFetchInstagram,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      return data;
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<Map<String, dynamic>> verifyAdd(addId) async {
    try {
      var token = PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {"token": token, "addId": addId};
      Response response = await dio.post(
        AppNetworkConstants.apiVerifyAdd,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = decrypt(response.data);
      return data;
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<bool> editUser(
      {required updatedData, required String phone}) async {
    try {
      String token =
          PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {"token": token, "_id": phone, "updatedData": updatedData};

      Response response = await dio.post(
        AppNetworkConstants.apiEditUser,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      bool isLoginSuccess = data["success"];
      print("-------------------------- updated data ${data}");
      if (isLoginSuccess) {
        await PreferenceUtils.setString(
          AppPreferenceConstants.LOGIN_KEY,
          json.encode(data["data"]),
        );
      }
      // ToDo : connect to nats
      return isLoginSuccess;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> activateFlag() async {
    try {
      String token =
          PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {"token": token};
      Response response = await dio.post(
        AppNetworkConstants.apiActivateFlag,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      bool isLoginSuccess = data["success"];
      print("-------------------------- updated data ${data}");
      if (isLoginSuccess) {
        await PreferenceUtils.setString(
          AppPreferenceConstants.LOGIN_KEY,
          json.encode(data["data"]),
        );
      }
      // ToDo : connect to nats
      return isLoginSuccess;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> fetchPaymentFlag() async {
    try {
      String token =
          PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {"token": token};

      Response response = await dio.post(
        AppNetworkConstants.apipaymentFlagVerification,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      bool isLoginSuccess = data["success"];
      print("-------------------------- updated data ${data}");
      if (isLoginSuccess) {
        await PreferenceUtils.setString(
          AppPreferenceConstants.LOGIN_KEY,
          json.encode(data["data"]),
        );
      }
      // ToDo : connect to nats
      return data["paymentFlag"];
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<Map<String, dynamic>> fetchYoutube() async {
    try {
      var token = PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {"token": token};
      Response response = await dio.post(
        AppNetworkConstants.apiFetchYoutube,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      return data;
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<Map<String, dynamic>> fetchInfluAdd() async {
    try {
      var token = PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {"token": token};
      Response response = await dio.post(
        AppNetworkConstants.apiFetchInfluAdd,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      return data;
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<Map<String, dynamic>> fetchComInfluAdd() async {
    try {
      var token = PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {"token": token};
      Response response = await dio.post(
        AppNetworkConstants.apiFetchComInfluAdd,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      return data;
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<Map<String, dynamic>> storeProfile(
      {required imageData, required String id}) async {
    try {
      var params = {"imageData": imageData, "id": id};
      Response response = await dio.post(
        AppNetworkConstants.apiProfile,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      final Map<String, dynamic> data = await decrypt(response.data);
      print(data);
      await PreferenceUtils.setString(
        AppPreferenceConstants.LOGIN_KEY,
        json.encode(data["data"]),
      );
      return data;
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<CustomResponse> paymentFlag() async {
    try {
      var params = {};
      Response response = await dio.post(
        AppNetworkConstants.apiPaymentFlag,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );

      if (response.statusCode == 401) {
        return CustomResponse(success: "retry");
      }
      final Map<String, dynamic> data = await decrypt(response.data);
      //  print(response.data);
      print("hiii");
      return CustomResponse(success: "true", data: data);
    } catch (e) {
      print("error ${e}");
      debugPrint(e.toString());
      return CustomResponse(success: "false");
    }
  }

  static Future<CustomResponse> encrypt() async {
    try {
      var token = PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {"isTesting": false, "token": token};
      Response response = await dio.post(
        AppNetworkConstants.apiEncrypt,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );

      if (response.statusCode == 401) {
        return CustomResponse(success: "retry");
      }
      final Map<String, dynamic> data = await decrypt(response.data);
      //  print(response.data);
      print("hiii");
      return CustomResponse(success: "true", data: data);
    } catch (e) {
      print("error ${e}");
      debugPrint(e.toString());
      return CustomResponse(success: "false");
    }
  }

  static Future<CustomResponse> addTransaction({
    required String token,
    required double amount,
    required bool isDeposit,
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String branch,
    required String bankName,
  }) async {
    try {
      var params = {
        "amount": amount,
        "token": token,
        "isDeposit": false,
        "accountHolderName": accountHolderName, // Provide the value if needed
        "accountNumber": accountNumber, // Provide the value if needed
        "ifscCode": ifscCode, // Provide the value if needed
        "branch": branch, // Provide the value if needed
        "bankName": bankName,
      };

      Response response = await dio.post(
        AppNetworkConstants.apiAddTransaction,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );

      if (response.statusCode == 401) {
        return CustomResponse(success: "retry");
      }

      final Map<String, dynamic> data = await decrypt(response.data);
      return CustomResponse(success: "true", data: data);
    } catch (e) {
      debugPrint(e.toString());
      return CustomResponse(success: "false");
    }
  }

  static Future<Object> addInstagram({
    required String username,
  }) async {
    try {
      var token = PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {
        "username": username,
        "token": token,
      };

      Response response = await dio.post(
        AppNetworkConstants.apiAddInstagram,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );

      if (response.statusCode == 401) {
        return CustomResponse(success: "retry");
      }

      final Map<String, dynamic> data = await decrypt(response.data);
      bool isLoginSuccess = data["success"];
      print("-------------------------- updated data ${data}");
      if (isLoginSuccess) {
        await PreferenceUtils.setString(
          AppPreferenceConstants.LOGIN_KEY,
          json.encode(data["data"]),
        );
      }
      // ToDo : connect to nats
      return isLoginSuccess;
    } catch (e) {
      debugPrint(e.toString());
      return CustomResponse(success: "false");
    }
  }

  static Future<Object> addYoutube({
    required String youtube,
  }) async {
    try {
      var token = PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      var params = {
        "youtube": youtube,
        "token": token,
      };

      Response response = await dio.post(
        AppNetworkConstants.apiAddYoutube,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );

      if (response.statusCode == 401) {
        return CustomResponse(success: "retry");
      }

      final Map<String, dynamic> data = await decrypt(response.data);
      bool isLoginSuccess = data["success"];
      print("-------------------------- updated data ${data}");
      if (isLoginSuccess) {
        await PreferenceUtils.setString(
          AppPreferenceConstants.LOGIN_KEY,
          json.encode(data["data"]),
        );
      }
      // ToDo : connect to nats
      return isLoginSuccess;
    } catch (e) {
      debugPrint(e.toString());
      return CustomResponse(success: "false");
    }
  }

  static Future<Map<String, dynamic>> fetchWallet(
      {required String token}) async {
    try {
      var params = {"token": token};
      Response response = await dio.post(
        AppNetworkConstants.apiFetchWallet,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = await decrypt(response.data);
        //final data = jsonDecode(response.data);
        bool isLoginSuccess = data["success"];
        print("response from server is ${isLoginSuccess}  ${data["data"]}");
        if (isLoginSuccess) {
          await PreferenceUtils.setString(
            AppPreferenceConstants.LOGIN_KEY,
            json.encode(data["data"]),
          );
          await PreferenceUtils.setString(
            AppPreferenceConstants.TOKEN_KEY,
            data["token"],
          );
          return {
            "success": true,
          };
        }
        return {
          "success": false,
        };
      } else {
        return {"success": "retry"};
      }
      // ToDo : connect to nats
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }

  static Future<Map<String, dynamic>> fetchTransaction(
      {required String token}) async {
    try {
      var params = {"token": token};
      Response response = await dio.post(
        AppNetworkConstants.apiFetchTransaction,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(params),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = await decrypt(response.data);
        //final data = jsonDecode(response.data);

        return {"success": true, "data": data["data"]};
      }
      return {
        "success": false,
      };
    } catch (e) {
      print("error");
      debugPrint(e.toString());
      return {
        "success": false,
      };
    }
  }
}
