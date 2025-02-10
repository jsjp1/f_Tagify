import 'package:flutter/material.dart';

import 'package:tagify/components/video/video_instance.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/api/video.dart';

class VideoWidget extends StatefulWidget {
  final String oauthId;

  const VideoWidget({super.key, required this.oauthId});

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double widgetWidth = MediaQuery.of(context).size.width * (0.9);
    final double widgetHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40.0,
            color: Colors.black,
          ),
          SizedBox(
            width: widgetWidth,
            height: widgetHeight,
            child: FutureBuilder<ApiResponse<List<Video>>>(
              future: fetchUserVideos(widget.oauthId),
              builder: (context, snapshot) {
                debugPrint("$snapshot");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError ||
                    snapshot.data == null ||
                    !snapshot.data!.success) {
                  return const Center(
                      child: Text("비디오를 불러올 수 없습니다.")); // TODO: Localization
                } else {
                  List<Video> videos = snapshot.data!.data ?? [];

                  if (videos.isEmpty) {
                    return const Center(
                        child: Text("표시할 비디오가 없습니다.")); // TODO: Localization
                  }

                  return ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (BuildContext ctx, int idx) {
                      return VideoInstance(
                        instanceWidth: widgetWidth,
                        instanceHeight: 200.0,
                        video: videos[idx],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
