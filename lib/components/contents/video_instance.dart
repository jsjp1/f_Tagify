import 'package:flutter/material.dart';

import 'package:tagify/global.dart';
import 'package:tagify/utils/time.dart';
import 'package:tagify/components/contents/common.dart';

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
      child: Align(
        alignment: Alignment.center,
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
                child: Container(
                  width: instanceWidth,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16.0),
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(200),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        video.thumbnail,
                        width: instanceWidth,
                        height: instanceHeight,
                        fit: BoxFit.fitWidth,
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
                                secTimeConvert(video.length),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: GlobalText(
                  isBold: true,
                  localizeText: video.title,
                  textColor: Colors.black,
                  textSize: 17.0,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlobalText(
                      localizeText:
                          video.tags.isNotEmpty ? "#${video.tags[0]} " : "",
                      textSize: 10.0,
                      isBold: false,
                      textColor: tagColor,
                      overflow: TextOverflow.clip),
                  GlobalText(
                      localizeText:
                          video.tags.isNotEmpty ? "#${video.tags[1]} " : "",
                      textSize: 10.0,
                      isBold: false,
                      textColor: tagColor,
                      overflow: TextOverflow.clip),
                  GlobalText(
                      localizeText:
                          video.tags.isNotEmpty ? "#${video.tags[2]} " : "",
                      textSize: 10.0,
                      isBold: false,
                      textColor: tagColor,
                      overflow: TextOverflow.clip),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
