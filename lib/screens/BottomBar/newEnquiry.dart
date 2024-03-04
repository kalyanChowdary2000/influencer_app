// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_local_variable, await_only_futures, dead_code, library_private_types_in_public_api, deprecated_member_use, use_key_in_widget_constructors, avoid_print, unused_element, sized_box_for_whitespace

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewEnquiryPage extends StatefulWidget {
  @override
  _NewEnquiryPageState createState() => _NewEnquiryPageState();
}

class _NewEnquiryPageState extends State<NewEnquiryPage> {
  var myAddsList = [];
  double downloadProgress = 0.0;
  bool globalFlag = false;
  void fetchAddData() async {
    var data = await AuthProvider.fetchInfluAdd(); // Replace with your API call
    print(data);

    if (data["data"].length != 0) {
      setState(() {
        myAddsList = data['data'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAddData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () async {
                setState(() {
                  globalFlag = !globalFlag;
                });
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                //    side: BorderSide(),
                backgroundColor: !globalFlag
                    ? Color.fromARGB(255, 99, 62, 151)
                    : Colors.grey,
              ),
              child: Text('My Ads', style: TextStyle(fontSize: 15)),
            ),
            // Text("        "),
            TextButton(
              onPressed: () async {
                setState(() {
                  globalFlag = !globalFlag;
                });
              },
              style: ElevatedButton.styleFrom(
                primary:
                    globalFlag ? Color.fromARGB(255, 99, 62, 151) : Colors.grey,
              ),
              child: Text('All Ads', style: TextStyle(fontSize: 15)),
            ),
          ],
        ),
        globalFlag ? _buildGlobalAdsList() : _buildAddsList(),
      ],
    ));
  }

  Widget _buildGlobalAdsList() {
    return const Center(
      child: Text(
        "Global Ads list is empty!",
      ),
    );
  }

  Widget _buildAddsList() {
    if (myAddsList.isEmpty) {
      return const Center(
        child: Text(
          "Ads list is empty!",
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (_, index) {
        return _buildNewOrderItem(myAddsList[index]);
      },
      separatorBuilder: (_, __) {
        return const Divider();
      },
      itemCount: myAddsList.length,
    );
  }

  void _copyDescriptionToClipboard(String description) {
    Clipboard.setData(ClipboardData(text: description));
    Fluttertoast.showToast(
      msg: "Description copied to clipboard",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
    );
  }

  Widget _buildNewOrderItem(myAddsList) {
    final socialMediaLinks = myAddsList["socialMediaLinks"] ?? [];
    bool isInstagramVerified =
        false; // You can set these values based on your verification logic
    bool isYouTubeVerified = false;
    List<Widget> imageWidgets = [];
    List<Widget> videoWidgets = [];
    List<Widget> linkWidgets = [];
    for (var link in socialMediaLinks) {
      bool isImage = link["imageFlag"];
      print("------------------------------------------");
      print(link["link"]);
      linkWidgets.add(_buildLinkWidget(link["link"]));
      if (isImage) {
        imageWidgets.add(_buildImageWidget(link["link"]));
      } else {
        videoWidgets.add(_buildVideoWidget(link["link"]));
      }
    }

    return InkWell(
      onTap: () {
        // _navigateToProductDetailPage(product);
      },
      child: Card(
        color: Color.fromARGB(255, 249, 249, 249),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            ListTile(
              title: Center(
                child: Text(
                  myAddsList['tittle'],
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  Text(
                    myAddsList['description'],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Downloadable Media Links",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: linkWidgets,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Platforms :"),
                myAddsList['instaFlag']
                    ? Container(
                        height: 60,
                        width: 60,
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Image.network(
                              'https://azhanaresources.s3.ap-south-1.amazonaws.com/images/instagram.png'),
                        ),
                      )
                    : Text(""),
                myAddsList['ytFlag']
                    ? Container(
                        height: 60,
                        width: 60,
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Image.network(
                              'https://azhanaresources.s3.ap-south-1.amazonaws.com/images/youtube_logo.png'),
                        ),
                      )
                    : Text(""),
              ],
            ),
            Container(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 20),
              height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    ...imageWidgets,
                    ...videoWidgets,
                  ],
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 65, 161, 236)),
                  ),
                  onPressed: () {
                    _copyDescriptionToClipboard(
                        "${myAddsList['description']}-${myAddsList["_id"]}");
                  },
                  child: Text("Copy Description"),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: isInstagramVerified && isYouTubeVerified
                  ? ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                        // You can adjust other properties like padding, shape, etc. as needed.
                      ),
                      onPressed: () {
                        // Handle the action when the posts are already verified
                        // For example, you can show a message or perform a different action.
                      },
                      child: Text("Verified"),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 65, 161,
                                236)), // Set the background color to pink
                        // You can adjust other properties like padding, shape, etc. as needed.
                      ),
                      onPressed: () async {
                        setState(() {
                          isInstagramVerified = false;
                          isYouTubeVerified = false;
                        });
                        var verificationResponse =
                            await AuthProvider.verifyAdd(myAddsList["_id"]);

                        if (verificationResponse['instaFlag']) {
                          setState(() {
                            isInstagramVerified = true;
                          });
                          print("----------------instagram verified");
                        }
                        if (verificationResponse['ytFlag']) {
                          setState(() {
                            isYouTubeVerified = true;
                          });
                          print("----------------------yt verified");
                        }
                        // verifyAdd(myAddsList["tittle"]);
                      },
                      child: isInstagramVerified || isYouTubeVerified
                          ? CircularProgressIndicator() // Show a loading indicator when verifying
                          : Text("Verify my post"),
                    ), // Button based on verification status
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLinkWidget(String url) {
    return GestureDetector(
      onTap: () async {
        await launchUrl(Uri.parse(url));
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(Icons.link),
            SizedBox(width: 5),
            Text(
              url, // Display link text
              style: TextStyle(
                color: const Color.fromARGB(255, 3, 126, 226),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
      ),
    );
  }

  Widget _buildVideoWidget(String videoUrl) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: VideoPlayerWidget(videoUrl: videoUrl),
    );
  }

  String _extractDirectImageUrl(String driveLink) {
    return driveLink;
  }

  String _extractDirectVideoUrl(String driveLink) {
    return driveLink;
  }

  // void verifyAdd(addId) async {
  //   var verificationResponse = await AuthProvider.verifyAdd(addId);

  //   if (verificationResponse['instaFlag']) {
  //     setState(() {
  //       isInstagramVerified = true;
  //     });
  //     print("----------------instagram verified");
  //   }
  //   if (verificationResponse['ytFlag']) {
  //     setState(() {
  //       isYouTubeVerified = true;
  //     });
  //     print("----------------------yt verified");
  //   }
  //   print(isInstagramVerified);
  //   print(isYouTubeVerified);
  // }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VideoPlayer(_controller),
        Center(
          child: IconButton(
            onPressed: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            },
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 50,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
