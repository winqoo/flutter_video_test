import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoScreen(),
    );
  }
}

class VideoScreen extends StatefulWidget {
  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  VideoPlayerController playerController;
  VoidCallback listener;
  bool _isPlaying = true;

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    playerController = VideoPlayerController.network(
      "https://api.geteve.de/videos/163913636",
      /**
       * there is a redirect to vimeoCdn, the link below is valid only for 10 minutes but as it contains .m3u8 extensions it works
       * https://skyfire.vimeocdn.com/1548254167-0xe0813745de4a080cc4e5f85979de4aa41de5568f/163913636/video/522934657,522934665,522934660,522934648/master.m3u8
       */
    )
      ..play()
      ..addListener(() {
        final bool isPlaying = playerController.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      ..addListener(() {
        if (playerController.value.initialized) {
          final int duration = playerController.value.duration.inSeconds;
          final int position = playerController.value.position.inSeconds;
          if (position == duration) {
            _close(context);
          }
        }
      })
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Container(
            color: Colors.black,
          ),
          Align(
            alignment: Alignment.center,
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return playerController.value.initialized
        ? AspectRatio(
            aspectRatio: playerController.value.aspectRatio,
            child: VideoPlayer(playerController),
          )
        : Center(
            child: CupertinoActivityIndicator(),
          );
  }

  void _close(BuildContext context) {
    Navigator.of(context).pop(false);
  }
}
