import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:influ_app/screens/menuPage.dart';
import 'package:influ_app/utils/app_constants.dart';
import 'package:influ_app/utils/app_preferences.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<String> selectedItems = [];
  List<String> allItems = [
    "Fashion/Clothing",
    "GAMING",
    "FMCG",
    "Devotional/Faith",
    "TECH & SOFTWARE",
    "BUILDING SUPPLIES",
    "HOME APPLIANCES",
    "Child Products",
    "Finance",
    "Beauty Products",
    "BAKERS",
    "GADGETS",
    "HOME SUPPLIES",
    "OFFICE SUPPLIES",
    "FURNITURE",
    "RESTAURANT",
    "EDUCATION COACHES",
    "Health/Fitness",
    "STOCK MARKET ADVISOR",
    "PROFESSIONAL PHOTOGRAPHER",
    "VIDEOGRAPHER",
    "LEGAL EXPERTS",
    "HEALTH",
    "ARTIST",
    "EVENT PLANNERS",
    "CHOREAGRAPHY",
    "AUTOMOBILE",
    "HOSPITAL",
    "TOURISM"
  ];

  void _toggleItemSelection(String item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
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
    Navigator.pop(context);
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
