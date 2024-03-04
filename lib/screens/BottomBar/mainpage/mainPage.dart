// ignore_for_file: file_names, prefer_const_constructors, sort_child_properties_last, unnecessary_brace_in_string_interps, avoid_print, avoid_unnecessary_containers, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors_in_immutables, prefer_const_literals_to_create_immutables

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:influ_app/screens/BottomBar/mainpage/catergories.dart';
import 'package:influ_app/screens/login/paymentPage.dart';
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
  String videoUrl =
      'https://azhanaresources.s3.ap-south-1.amazonaws.com/influ/videos/influ_instructions.mp4';
  int reach = 0;
  String youtubeId = '';
  String youtubeFollowersCount = '';
  String youtubeEngagementRate = '';
  int youtubeReach = 0;
  var runningAddsList = [];
  bool instagramFlag = false;
  bool youtubeFlag = false;
  bool paymentFlag = false;
  bool isLoading = false;
  void refreshInstagramData() {
    fetchInstagramData();
  }

  void refreshYoutubeData() {
    fetchYoutubeData();
  }

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
    print('login data is -------- ${data}');

    var instagramData = await AuthProvider.fetchInstagram();
    print("intagram data is --------${instagramData}");
    if (instagramData["data"].length != 0) {
      setState(() {
        instagramId = instagramData["data"]["_id"];
        followersCount =
            formatFollowerCount(instagramData["data"]["followerCount"]);
        engagementRate =
            instagramData["data"]["engagementRate"].toStringAsFixed(2);
        reach = (instagramData["data"]["reach"] / 100).toInt();
        instagramFlag = true;
      });
    }
  }

  void fetchPaymentFlag() async {
    try {
      var authResponse = await AuthProvider.fetchPaymentFlag();
      print(
          "================================================================ auth responses ${authResponse}");
      setState(() {
        paymentFlag = authResponse;
        isLoading = true;
      });
      if (paymentFlag) {
        fetchRunningAdds();
      }
    } catch (e) {
      //print("jlshbdclabhsjcdjsacblkajsdclasbhjdbaksjdc");
      print(e);
    }
  }

  void fetchYoutubeData() async {
    var data = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    print('login data is ${data}');

    var youtubeData = await AuthProvider.fetchYoutube();
    print("---------- youtube data ------------- ${youtubeData}");

    if (youtubeData["data"] != null && youtubeData["data"].length != 0) {
      setState(() {
        int? fc = int.tryParse(youtubeData["data"]["followerCount"]);
        youtubeId = youtubeData["data"]["customUrl"];
        if (fc != null) {
          youtubeFollowersCount = formatFollowerCount(fc);
        }
        youtubeEngagementRate =
            youtubeData["data"]["engagementRate"].toStringAsFixed(2);
        youtubeReach = (youtubeData["data"]["reach"] / 100).toInt();
        youtubeFlag = true;
      });
    }
  }

  void fetchRunningAdds() async {
    if (paymentFlag) {
      var data = await AuthProvider.fetchComInfluAdd();
      print(
          "=================================++++++++++++++++++++++=========================");
      print(data["data"].length);
      setState(() {
        runningAddsList = data["data"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInstagramData();
    fetchYoutubeData();
    fetchPaymentFlag();
    fetchRunningAdds();
    print(
        "========================================================== ${paymentFlag}");
  }

  Widget buildRunningAddsList() {
    print("==========================================================");
    print(runningAddsList.length);
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (_, index) {
        return buildNewOrderItem(runningAddsList[index]);
      },
      separatorBuilder: (_, __) {
        return const Divider();
      },
      itemCount: runningAddsList.length,
    );
  }

  Widget buildNewOrderItem(myAddsList) {
    return Container(
      color: Colors.red,
      child: Text("${myAddsList}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    !instagramFlag
                        ? Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      final accountId = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return LinkInstagramDialog(
                                              refreshCallback:
                                                  refreshInstagramData);
                                        },
                                      );

                                      if (accountId != null) {
                                        // Process the 'accountId' (Instagram ID) as needed.
                                        // You can make an API request to link the account.
                                      }
                                    },
                                    child: Text("Link Instagram")),
                                GestureDetector(
                                  onTap: () async {
                                    await launchUrl(Uri.parse(videoUrl));
                                  },
                                  child: Icon(
                                    Icons.question_mark_outlined,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () async {
                                    await launchUrl(Uri.parse(
                                        '${AppPreferenceConstants.appInstaPromoUrl}${instagramId}'));
                                    print("insta tap");
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
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
                                SizedBox(width: 20),
                                Column(
                                  children: [
                                    Container(
                                      child: Text(
                                        "${reach}",
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 213, 68, 117),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        "Reach",
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
                    !youtubeFlag
                        ? Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      final accountId = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return LinkYoutubeDialog(
                                              refreshCallback:
                                                  refreshYoutubeData);
                                        },
                                      );

                                      if (accountId != null) {
                                        // Process the 'accountId' (YouTube ID) as needed.
                                        // You can make an API request to link the account.
                                      }
                                    },
                                    child: Text("Link YouTube")),
                                GestureDetector(
                                  onTap: () async {
                                    await launchUrl(Uri.parse(videoUrl));
                                  },
                                  child: Icon(
                                    Icons.question_mark_outlined,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              // //crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () async {
                                    await launchUrl(Uri.parse(
                                        '${AppPreferenceConstants.appYoutubePromoUrl}${youtubeId}'));
                                    print("youtube tap");
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
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
                                            color: Color.fromARGB(
                                                255, 219, 49, 49),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        "Subscribers",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 219, 49, 49),
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
                                            color: Color.fromARGB(
                                                255, 219, 49, 49),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        "Engagement\nRate",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 219, 49, 49),
                                            fontSize: 10,
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
                                        "${youtubeReach}",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 219, 49, 49),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        "Reach",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 219, 49, 49),
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
                      height: 20,
                    ),
                  ]),
            )),
        // Expanded(
        //     flex: 4,
        //     child: Column(
        //       children: [
        //         SizedBox(
        //           height: 30,
        //         ),
        //         Container(
        //           child: Text(
        //             "${formatFollowerCount((reach + youtubeReach) as int)}",
        //             style: TextStyle(
        //                 color: Color.fromARGB(255, 155, 42, 80),
        //                 fontSize: 48,
        //                 fontWeight: FontWeight.bold),
        //           ),
        //         ),
        //         Container(
        //           child: Text(
        //             "Overall Reach",
        //             style: TextStyle(
        //                 color: Color.fromARGB(255, 160, 38, 79),
        //                 fontSize: 18,
        //                 fontWeight: FontWeight.bold),
        //           ),
        //         ),
        //         SizedBox(
        //           height: 5,
        //         ),
        //         instagramFlag
        //             ? SingleChildScrollView(
        //                 scrollDirection: Axis.horizontal,
        //                 child: Row(
        //                   children: [
        //                     Container(
        //                       height: 25,
        //                       width: 25,
        //                       child: Image.network(
        //                           "https://azhanaresources.s3.ap-south-1.amazonaws.com/images/instagram.png"),
        //                     ),
        //                     Container(
        //                       child: Text("@${instagramId}"),
        //                     )
        //                   ],
        //                 ),
        //               )
        //             : ElevatedButton(
        //                 onPressed: () async {
        //                   final accountId = await showDialog(
        //                     context: context,
        //                     builder: (context) {
        //                       return LinkInstagramDialog(
        //                           refreshCallback: refreshInstagramData);
        //                     },
        //                   );

        //                   if (accountId != null) {
        //                     // Process the 'accountId' (Instagram ID) as needed.
        //                     // You can make an API request to link the account.
        //                   }
        //                 },
        //                 child: Text("Link Instagram")),
        //         SizedBox(
        //           height: 5,
        //         ),
        //         youtubeFlag
        //             ? SingleChildScrollView(
        //                 scrollDirection: Axis.horizontal,
        //                 child: Row(
        //                   children: [
        //                     Container(
        //                       height: 25,
        //                       width: 25,
        //                       child: Image.network(
        //                           "https://azhanaresources.s3.ap-south-1.amazonaws.com/images/youtube_logo.png"),
        //                     ),
        //                     Container(
        //                       child: Text("${youtubeId}"),
        //                     )
        //                   ],
        //                 ),
        //               )
        //             : ElevatedButton(
        //                 onPressed: () async {
        //                   final accountId = await showDialog(
        //                     context: context,
        //                     builder: (context) {
        //                       return LinkYoutubeDialog(
        //                           refreshCallback: refreshYoutubeData);
        //                     },
        //                   );

        //                   if (accountId != null) {
        //                     // Process the 'accountId' (YouTube ID) as needed.
        //                     // You can make an API request to link the account.
        //                   }
        //                 },
        //                 child: Text("Link Youtube"))
        //       ],
        //     ))

        Expanded(
            child: GestureDetector(
              onTap: () {
                print("customize your category tap---------------------------");
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                )),
              ),
            ),
            flex: 1),
        isLoading
            ? paymentFlag
                ? Expanded(
                    flex: 6,
                    child: Container(
                      child: Column(children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Text(
                            "My Running Campaigns",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: runningAddsList.length == 0
                              ? Center(
                                  child: Container(
                                  child:
                                      Text("You Don't Have Any Campaigns Yet"),
                                ))
                              : Container(
                                  color: Colors.white,
                                  child: ListView.builder(
                                    itemCount: runningAddsList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      print("++++++++++++++++++++");
                                      print(runningAddsList[index]);
                                      bool ytLogs = false;
                                      bool instaLogs = false;
                                      if (runningAddsList[index]["instaData"] !=
                                          null) {
                                        instaLogs = true;
                                      }
                                      var instaData =
                                          runningAddsList[index]["instaData"];
                                      if (runningAddsList[index]["ytData"] !=
                                          null) {
                                        ytLogs = true;
                                      }
                                      var ytData =
                                          runningAddsList[index]["ytData"];
                                      return Card(
                                          color: Color.fromARGB(
                                              255, 232, 245, 246),
                                          elevation: 4,
                                          clipBehavior: Clip.antiAlias,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                child: Center(
                                                  child: Text(
                                                    "${runningAddsList[index]["addData"]["tittle"]}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              !instaLogs
                                                  ? Center(
                                                      child: Text(
                                                          "instagram is not linke dto this ad"),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Container(
                                                          height: 50,
                                                          width: 50,
                                                          child: Padding(
                                                            padding: EdgeInsets.all(
                                                                2.0), // Adjust the padding as needed
                                                            child: Image.network(
                                                                'https://azhanaresources.s3.ap-south-1.amazonaws.com/images/instagram.png'), // Replace with your image path
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(Icons.favorite,
                                                                color: Colors
                                                                    .red), // Heart icon for likes
                                                            SizedBox(
                                                                width:
                                                                    4), // Add some spacing
                                                            Text(instaData[
                                                                    "likes"]
                                                                .toString()), // Display likes count
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        // Display Instagram comments with an icon
                                                        Row(
                                                          children: [
                                                            Icon(Icons.comment,
                                                                color: Colors
                                                                    .blue), // Comment icon
                                                            SizedBox(width: 4),
                                                            Text(instaData[
                                                                    "comments"]
                                                                .toString()), // Display comments count
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              !ytLogs
                                                  ? Center(
                                                      child: Text(
                                                          "youtube is not linke dto this ad"),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Container(
                                                          height: 50,
                                                          width: 50,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    2.0),
                                                            child:
                                                                Image.network(
                                                              'https://azhanaresources.s3.ap-south-1.amazonaws.com/images/youtube_logo.png',
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(Icons.thumb_up,
                                                                color: Colors
                                                                    .blue), // Thumbs-up icon for likes
                                                            SizedBox(width: 4),
                                                            Text(ytData[
                                                                    "likeCount"]
                                                                .toString()), // Display likes count
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        // Display YouTube comments with an icon
                                                        Row(
                                                          children: [
                                                            Icon(Icons.comment,
                                                                color: Colors
                                                                    .red), // Comment icon
                                                            SizedBox(width: 4),
                                                            Text(ytData[
                                                                    "commentCount"]
                                                                .toString()), // Display comments count
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        // Display YouTube likes with an icon
                                                        Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .remove_red_eye,
                                                                color: Colors
                                                                    .red), // Views icon
                                                            SizedBox(width: 4),
                                                            Text(ytData[
                                                                    "viewCount"]
                                                                .toString()), // Display views count
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ));
                                    },
                                  ),
                                ),
                        ),
                      ]),
                    ),
                  )
                : Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                            'https://azhanaresources.s3.ap-south-1.amazonaws.com/influ/images/Beoinflencer-earning-point+(1).png'),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PaymentPage()),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Text("Activate"),
                                      Icon(Icons.shield)
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ))
            : Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 100,
                        width: 100,
                        child: Card(
                            elevation: 4,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              color: Colors.black,
                              // backgroundColor: Colors.amber,
                            ))),
                  ],
                ))
      ],
    );
  }
}

class LinkInstagramDialog extends StatefulWidget {
  final Function refreshCallback;

  LinkInstagramDialog({required this.refreshCallback});
  @override
  _LinkInstagramDialogState createState() => _LinkInstagramDialogState();
}

class _LinkInstagramDialogState extends State<LinkInstagramDialog> {
  int _generateRandomCode() {
    final random = Random();
    return random.nextInt(900000) + 100000; // Generates a random 6-digit number
  }

  String accountId = '';
  bool _isVerified = false;
  int _verificationCode = 0;
  bool _instagramFlag = false;
  TextEditingController _instagramIdController = TextEditingController();

  void _verifyAccount() async {
    setState(() {
      _isVerified = true;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _verificationCode = _generateRandomCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Link Instagram Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your Instagram ID and add the verification code to your bio',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _instagramIdController,
            decoration: InputDecoration(
              labelText: 'Instagram ID',
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$_verificationCode', style: TextStyle(fontSize: 20)),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: '$_verificationCode'));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Verification code copied to clipboard'),
                    ));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () => {Navigator.pop(context)},
          child: Text('Close'),
          style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 65, 161, 236)),
        ),
        ElevatedButton(
          onPressed: _isVerified
              ? () {
                  Navigator.of(context).pop(); // Close the dialog
                }
              : () async {
                  var instagramId = _instagramIdController.text;
                  if (instagramId.isNotEmpty) {
                    var authResponse = await AuthProvider.verifyInstagram(
                        username: instagramId,
                        verificationCode: '${_verificationCode}');
                    setState(() {
                      _isVerified = authResponse['success'];
                    });
                    if (_isVerified) {
                      _instagramFlag = true;
                      await AuthProvider.addInstagram(username: instagramId);
                      widget.refreshCallback();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Account verified successfully'),
                      ));
                    } else {
                      // Show an error message
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Verification failed. Please try again.'),
                      ));
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Account verified successfully'),
                    ));
                  } else {
                    // Show an error message if Instagram ID is not entered
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please enter your Instagram ID.'),
                    ));
                  }
                },
          child: Text(_isVerified ? 'Verified' : 'Verify Account'),
          style: ElevatedButton.styleFrom(
            primary:
                _isVerified ? Colors.green : Color.fromARGB(255, 65, 161, 236),
          ),
        ),
      ],
    );
  }
}

class LinkYoutubeDialog extends StatefulWidget {
  final Function refreshCallback;

  LinkYoutubeDialog({required this.refreshCallback});
  @override
  _LinkYoutubeDialogState createState() => _LinkYoutubeDialogState();
}

class _LinkYoutubeDialogState extends State<LinkYoutubeDialog> {
  int _generateRandomCode() {
    final random = Random();
    return random.nextInt(900000) + 100000; // Generates a random 6-digit number
  }

  String accountId = '';
  bool _isVerified = false;
  int _verificationCode = 0;
  bool _ytFlag = false;
  TextEditingController _youtubeController = TextEditingController();

  void _verifyAccount() async {
    setState(() {
      _isVerified = true;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _verificationCode = _generateRandomCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Link Youtube Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your Youtube channel Link and add the verification code to your description',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _youtubeController,
            decoration: InputDecoration(
              labelText: 'Youtube Link',
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$_verificationCode', style: TextStyle(fontSize: 20)),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: '$_verificationCode'));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Verification code copied to clipboard'),
                    ));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () => {Navigator.pop(context)},
          child: Text('Close'),
          style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 65, 161, 236)),
        ),
        ElevatedButton(
          onPressed: _isVerified
              ? () {
                  Navigator.of(context).pop(); // Close the dialog
                }
              : () async {
                  var ytChannelLink = _youtubeController.text;
                  if (ytChannelLink.isNotEmpty) {
                    var authResponse = await AuthProvider.verifyYoutbe(
                        channelLink: ytChannelLink,
                        verificationCode: _verificationCode);
                    setState(() {
                      _isVerified = authResponse['success'];
                    });
                    if (_isVerified) {
                      _ytFlag = true;
                      await AuthProvider.addYoutube(
                          youtube: authResponse['channelId']);
                      widget.refreshCallback();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Account verified successfully'),
                      ));
                    } else {
                      // Show an error message
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Verification failed. Please try again.'),
                      ));
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Account verified successfully'),
                    ));
                  } else {
                    // Show an error message if Instagram ID is not entered
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please enter your Instagram ID.'),
                    ));
                  }
                },
          child: Text(_isVerified ? 'Verified' : 'Verify Account'),
          style: ElevatedButton.styleFrom(
            primary:
                _isVerified ? Colors.green : Color.fromARGB(255, 65, 161, 236),
          ),
        ),
      ],
    );
  }
}
