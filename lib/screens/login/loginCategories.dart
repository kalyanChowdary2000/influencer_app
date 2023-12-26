import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:influ_app/screens/login/paymentPage.dart';
import 'package:influ_app/screens/menuPage.dart';
import 'package:influ_app/utils/app_constants.dart';
import 'package:influ_app/utils/app_preferences.dart';

class LoginCategoriesPage extends StatefulWidget {
  @override
  _LoginCategoriesPageState createState() => _LoginCategoriesPageState();
}

class _LoginCategoriesPageState extends State<LoginCategoriesPage> {
  List<String> selectedItems = [];
  List<String> allItems = [
    "FASHION",
    "GAMING",
    "FMCG",
    "DEVOTIONAL",
    "TECH/SOFTWARE",
    "BUILDING MATERIALS",
    "HOME APPLIANCES",
    "KIDS WELLBEING",
    "FINANCE",
    "BEAUTY PRODUCTS",
    "GADGETS",
    "HOME SUPPLIES",
    "STATIONARIES",
    "FURNITURE",
    "FOOD/RESTAURANT",
    "EDUCATION",
    "HEALTH/FITNESS",
    "STOCK MARKET",
    "PHOTOGRAPHY",
    "LEGAL EXPERTS",
    "ARTIST",
    "EVENT PLANNERS",
    "CHOREOGRAPHY",
    "AUTOMOBILE",
    "TOURISM",
    "SERVICE PROVIDER",
    "SPORTS"
  ];

  void _toggleItemSelection(String item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        // Check if the user has already selected 5 items
        if (selectedItems.length < 5) {
          selectedItems.add(item);
        } else {
          // You can show a message to the user indicating that they can only select 5 items
          // For example, you can use a SnackBar:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can only select up to 5 items.'),
            ),
          );
        }
      }
    });
  }

  void save() async {
    var data = PreferenceUtils.getString(
      AppPreferenceConstants.LOGIN_KEY,
    );
    var userData = json.decode(data);
    await AuthProvider.editUser(
        updatedData: {"category": selectedItems}, phone: userData["_id"]);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MenuPage()),
    );
  }

  void fetchData() async {
    var data = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    var userData = json.decode(data);
    print(
        '---------------------------------------------------------------------------------------');
    print('user data is ${userData}');
    setState(() {
      for (int i = 0; i < userData["category"].length; i++) {
        selectedItems.add(userData["category"][i].toString());
      }
      print(selectedItems);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Item Selection"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index];
                final isSelected = selectedItems.contains(item);

                return ListTile(
                  title: Text(item),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.circle_outlined),
                  onTap: () => _toggleItemSelection(item),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print("Selected Items: $selectedItems");
              save();
            },
            child: Text("Save"),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
