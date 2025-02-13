import 'package:flutter/material.dart';

import 'package:tagify/components/contents/content_instance.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/global.dart';
import 'package:tagify/components/contents/common.dart';

class ContentWidget extends StatefulWidget {
  final String oauthId;

  const ContentWidget({super.key, required this.oauthId});

  @override
  ContentWidgetState createState() => ContentWidgetState();
}

class ContentWidgetState extends State<ContentWidget> {
  late Future<ApiResponse<List<Video>>> _futureVideos;

  @override
  void initState() {
    super.initState();
    _futureVideos = fetchUserVideos(widget.oauthId);
  }

  Future<void> _refreshContent() async {
    setState(() {
      _futureVideos = fetchUserVideos(widget.oauthId); // TODO: 최적화 -> 새로운 것들만
    });
  }

  @override
  Widget build(BuildContext context) {
    final double widgetWidth = MediaQuery.of(context).size.width * (0.9);

    return RefreshIndicator.adaptive(
      elevation: 30.0,
      displacement: 10.0,
      edgeOffset: -10.0,
      backgroundColor: Colors.transparent,
      color: Colors.black,
      onRefresh: _refreshContent,
      child: FutureBuilder<ApiResponse<List<Video>>>(
        future: _futureVideos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              snapshot.data == null ||
              !snapshot.data!.success) {
            return Center(
              child: GlobalText(
                localizeText: "content_widget_failure",
                textSize: 15.0,
                isBold: true,
                textColor: Colors.black,
                overflow: TextOverflow.clip,
              ),
            );
          } else {
            List<Video> videos = snapshot.data!.data ?? [];

            if (videos.isEmpty) {
              return Center(
                child: GlobalText(
                  localizeText: "content_widget_empty",
                  textSize: 15.0,
                  isBold: true,
                  textColor: Colors.black,
                  overflow: TextOverflow.clip,
                ),
              );
            }

            return ListView.builder(
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
                        localizeText: "content_widget_end",
                        overflow: TextOverflow.clip,
                        textColor: Colors.grey,
                        textSize: 15.0,
                      ),
                    ),
                  );
                }

                return ContentInstance(
                  instanceWidth: widgetWidth,
                  instanceHeight: 200.0,
                  content: videos[idx],
                );
              },
            );
          }
        },
      ),
    );
  }
}
