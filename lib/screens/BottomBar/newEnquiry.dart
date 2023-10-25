// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

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
  bool isInstagramVerified =
      false; // You can set these values based on your verification logic
  bool isYouTubeVerified = false;
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
    return SafeArea(child: _buildAddsList());
  }

  Widget _buildAddsList() {
    if (myAddsList.isEmpty) {
      return const Center(
        child: Text(
          "Adds list is empty!",
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

    Widget copyDescriptionButton = ElevatedButton(
      onPressed: () {
        _copyDescriptionToClipboard(myAddsList['description']);
      },
      child: Text("Copy"),
    );

    return Card(
      color: Color.fromARGB(255, 240, 240, 239),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            title: Center(
              child: Flexible(
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
                      fontWeight: FontWeight.bold),
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
                        padding:
                            EdgeInsets.all(2.0), // Adjust the padding as needed
                        child: Image.network(
                            'https://azhanaresources.s3.ap-south-1.amazonaws.com/images/instagram.png'), // Replace with your image path
                      ),
                    )
                  : Text(""),
              myAddsList['ytFlag']
                  ? Container(
                      height: 60,
                      width: 60,
                      child: Padding(
                        padding:
                            EdgeInsets.all(2.0), // Adjust the padding as needed
                        child: Image.network(
                            'https://azhanaresources.s3.ap-south-1.amazonaws.com/images/youtube_logo.png'), // Replace with your image path
                      ),
                    )
                  : Text("")
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
          SizedBox(
              width: double.infinity, // Make the button as wide as the card
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromARGB(
                      255, 43, 32, 99)), // Set the background color to pink
                  // You can adjust other properties like padding, shape, etc. as needed.
                ),
                onPressed: () {
                  _copyDescriptionToClipboard(myAddsList['description']);
                },
                child: Text("Copy Description"),
              )),
          SizedBox(
            width: double.infinity, // Make the button as wide as the card
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color.fromARGB(
                    255, 43, 32, 99)), // Set the background color to pink
                // You can adjust other properties like padding, shape, etc. as needed.
              ),
              onPressed: () {
                _showVerifyDialog(context, myAddsList["tittle"]);
              },
              child: Text("verify my post"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLinkWidget(String url) {
    return GestureDetector(
      onTap: () async {
        await launchUrl(Uri.parse(url));
        // Open the link in the browser (Chrome)
        // You can use the 'url_launcher' package to achieve this.
        // Make sure to add the package to your dependencies.
        // Example: https://pub.dev/packages/url_launcher
        // Import the package and use it to launch the URL.
        // launch(url);
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

  void verifyAdd(addId) async {
    await AuthProvider.verifyAdd(addId);
  }

  void _showVerifyDialog(BuildContext context, addId) {
    // You can set these values based on your verification logic
    verifyAdd(addId);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Verify Instagram and YouTube Posts"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Please verify your Instagram and YouTube posts here."),
                  if (!isInstagramVerified)
                    Column(
                      children: [
                        Text("Verifying Instagram..."),
                        LinearProgressIndicator(), // Loading bar for Instagram
                      ],
                    ),
                  if (!isYouTubeVerified)
                    Column(
                      children: [
                        Text("Verifying YouTube..."),
                        LinearProgressIndicator(), // Loading bar for YouTube
                      ],
                    ),
                  // You can add more content as needed.
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog.
                  },
                  child: Text("Close"),
                ),
                TextButton(
                  onPressed: () {
                    // Simulate verification logic (you can replace this with your actual logic).
                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        isInstagramVerified = true;
                      });
                    });

                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        isYouTubeVerified = true;
                      });
                    });

                    // You can perform actual verification logic here.
                  },
                  child: Text("Verify"),
                ),
              ],
            );
          },
        );
      },
    );
  }
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
