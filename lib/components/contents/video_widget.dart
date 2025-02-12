import 'package:flutter/material.dart';

import 'package:tagify/components/contents/video_instance.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/api/video.dart';
import 'package:tagify/global.dart';
import 'package:tagify/components/contents/common.dart';

class VideoWidget extends StatefulWidget {
  final String oauthId;

  const VideoWidget({super.key, required this.oauthId});

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double widgetWidth = MediaQuery.of(context).size.width * (0.9);

    return FutureBuilder<ApiResponse<List<Video>>>(
      future: fetchUserVideos(widget.oauthId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 대기중
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            snapshot.data == null ||
            !snapshot.data!.success) {
          // 영상 가져오기 실패
          return const Center(
            child: GlobalText(
              localizeText: "video_widget_failure",
              textSize: 15.0,
              isBold: true,
              textColor: Colors.black,
              overflow: TextOverflow.clip,
            ),
          );
        } else {
          // 정상 작동
          List<Video> videos = snapshot.data!.data ?? [];

          // 유저에 해당하는 비디오 없음
          if (videos.isEmpty) {
            return const Center(
              child: GlobalText(
                localizeText: "video_widget_empty",
                textSize: 15.0,
                isBold: true,
                textColor: Colors.black,
                overflow: TextOverflow.clip,
              ),
            );
          }

          return ListView.builder(
            controller: PrimaryScrollController.of(context),
            itemCount: videos.length + 1,
            itemBuilder: (BuildContext ctx, int idx) {
              if (idx == videos.length) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    height: 75.0,
                    child: GlobalText(
                      isBold: false,
                      localizeText: "video_widget_end",
                      overflow: TextOverflow.clip,
                      textColor: Colors.grey,
                      textSize: 15.0,
                    ),
                  ),
                );
              }

              return VideoInstance(
                instanceWidth: widgetWidth,
                instanceHeight: 265.0,
                video: videos[idx],
              );
            },
          );
        }
      },
    );
  }
}
