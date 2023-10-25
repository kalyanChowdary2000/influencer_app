// ignore_for_file: file_names, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:influ_app/screens/BottomBar/mainpage/catergories.dart';
import 'package:influ_app/utils/app_constants.dart';
import 'package:influ_app/utils/app_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String instagramId = '';
  String followersCount = '';
  String engagementRate = '';
  int reach = 0;
  String youtubeId = '';
  String youtubeFollowersCount = '';
  String youtubeEngagementRate = '';
  int youtubeReach = 0;
  String formatFollowerCount(int followerCount) {
    if (followerCount >= 1000000) {
      double countInMillions = followerCount / 1000000;
      return '${countInMillions.toStringAsFixed(1)}M';
    } else if (followerCount >= 1000) {
      double countInThousands = followerCount / 1000;
      return '${countInThousands.toStringAsFixed(1)}K';
    } else {
      return followerCount.toString();
    }
  }

  void fetchInstagramData() async {
    var data = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    print('login data is ${data}');

    var instagramData = await AuthProvider.fetchInstagram();
    print(instagramData);
    print(instagramData["data"]["_id"]);
    setState(() {
      instagramId = instagramData["data"]["_id"];
      followersCount =
          formatFollowerCount(instagramData["data"]["followerCount"]);
      engagementRate =
          instagramData["data"]["engagementRate"].toStringAsFixed(2);
      reach = (instagramData["data"]["reach"] / 100).toInt();
    });
  }

  void fetchYoutubeData() async {
    var data = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    print('login data is ${data}');

    var youtubeData = await AuthProvider.fetchYoutube();
    print(youtubeData);
    print(youtubeData["data"]["_id"]);
    setState(() {
      int? fc = int.tryParse(youtubeData["data"]["followerCount"]);
      youtubeId = youtubeData["data"]["customUrl"];
      if (fc != null) {
        youtubeFollowersCount = formatFollowerCount(fc);
      }
      youtubeEngagementRate =
          youtubeData["data"]["engagementRate"].toStringAsFixed(2);
      youtubeReach = (youtubeData["data"]["reach"] / 100).toInt();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchInstagramData();
    fetchYoutubeData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            flex: 3,
            child: Row(children: [
              Expanded(
                  flex: 6,
                  child: Container(
                    color: Colors.white,
                    child: Column(children: [
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Container(
                          child: Text(
                            "Social Media Manager",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () async {
                                await launchUrl(Uri.parse(
                                    '${AppPreferenceConstants.appInstaPromoUrl}${instagramId}'));
                                print("insta tap");
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      2.0), // Adjust the padding as needed
                                  child: Image.network(
                                      'https://azhanaresources.s3.ap-south-1.amazonaws.com/images/instagram.png'), // Replace with your image path
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              children: [
                                Container(
                                  child: Text(
                                    "${followersCount}",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 213, 68, 117),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "Followers",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 213, 68, 117),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 20),
                            Column(
                              children: [
                                Container(
                                  child: Text(
                                    "${engagementRate}",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 213, 68, 117),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "Engagement\nRate",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 213, 68, 117),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () async {
                                await launchUrl(Uri.parse(
                                    '${AppPreferenceConstants.appYoutubePromoUrl}${youtubeId}'));
                                print("youtube tap");
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      2.0), // Adjust the padding as needed
                                  child: Image.network(
                                      'https://azhanaresources.s3.ap-south-1.amazonaws.com/images/youtube_logo.png'), // Replace with your image path
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              children: [
                                Container(
                                  child: Text(
                                    "${youtubeFollowersCount}",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 219, 49, 49),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "Subscribers",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 219, 49, 49),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 20),
                            Column(
                              children: [
                                Container(
                                  child: Text(
                                    "${youtubeEngagementRate}",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 219, 49, 49),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "Engagement\nRate",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 219, 49, 49),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
                  )),
              Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        child: Text(
                          "${formatFollowerCount((reach + youtubeReach) as int)}",
                          style: TextStyle(
                              color: Color.fromARGB(255, 155, 42, 80),
                              fontSize: 48,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        child: Text(
                          "Overall Reach",
                          style: TextStyle(
                              color: Color.fromARGB(255, 160, 38, 79),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              child: Image.network(
                                  "https://azhanaresources.s3.ap-south-1.amazonaws.com/images/instagram.png"),
                            ),
                            Container(
                              child: Text("@${instagramId}"),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              child: Image.network(
                                  "https://azhanaresources.s3.ap-south-1.amazonaws.com/images/youtube_logo.png"),
                            ),
                            Container(
                              child: Text("${youtubeId}"),
                            )
                          ],
                        ),
                      )
                    ],
                  ))
            ])),
        Expanded(
            child: GestureDetector(
              onTap: () {
                print(
                    "customize ypout category tap---------------------------");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesPage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // Set the border color
                    width: 1.0, // Set the border width
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                //color: Colors.amber,
                child: Center(
                    child: Text(
                  "Customize Your Category >>",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
              ),
            ),
            flex: 1),
        Expanded(
            flex: 6,
            child: Container(color: Color.fromARGB(255, 212, 213, 215))),
      ],
    );
  }
}
