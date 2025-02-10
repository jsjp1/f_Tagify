import 'package:flutter/material.dart';
import 'package:tagify/global.dart';

class Video {
  final String url;
  final String title;
  final int length;
  final String thumbnail;
  final List<String> tags;

  Video(
      {required this.url,
      required this.title,
      required this.length,
      required this.thumbnail,
      required this.tags});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      url: json["url"] ?? "",
      title: json["title"],
      length: json["video_length"],
      thumbnail: json["thumbnail"],
      tags: List<String>.from(json["tags"] ?? []),
    );
  }
}

class VideoInstance extends StatelessWidget {
  final double instanceWidth;
  final double instanceHeight;
  final Video video;

  const VideoInstance({
    super.key,
    required this.instanceWidth,
    required this.instanceHeight,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Container(
        width: instanceWidth,
        height: instanceHeight,
        decoration: BoxDecoration(
          color: videoTextBarColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                child: Stack(
                  children: [
                    Image.network(
                      video.thumbnail,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: timeContainerColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              video.length.toString(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlobalText(
                    isBold: true,
                    localizeText: video.title,
                    textColor: Colors.black,
                    textSize: 15.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
