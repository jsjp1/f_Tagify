import 'package:flutter/material.dart';

import 'package:tagify/components/contents/content_instance.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/global.dart';
import 'package:tagify/components/contents/common.dart';

class ContentWidget extends StatefulWidget {
  final int userId;
  final GlobalKey<ContentWidgetState>? key;
  String tagName;

  ContentWidget({this.key, required this.userId, required this.tagName})
      : super(key: key);

  @override
  ContentWidgetState createState() => ContentWidgetState();
}

class ContentWidgetState extends State<ContentWidget> {
  late Future<ApiResponse<List<Content>>> _futureContents;

  @override
  void initState() {
    super.initState();
    _futureContents = fetchUserContents(widget.userId);
  }

  void setTagName(String newTagName) {
    setState(() {
      widget.tagName = newTagName;
    });
  }

  Future<void> refreshContents() async {
    setState(() {
      _futureContents =
          fetchUserContents(widget.userId); // TODO: 최적화 -> 새로운 것들만
    });
  }

  Future<void> refreshBookmarkContents() async {
    setState(() {
      _futureContents = fetchBookmarkContents(widget.userId);
    });
  }

  Future<void> refreshTagContents(String tagName) async {
    setState(() {
      // TODO: 특정 태그 입력 -> 해당 태그의 콘텐츠 불러오기
      // _futureContents = fetchTagContents(widget.userId);
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
      onRefresh: widget.tagName == "all"
          ? refreshContents
          : (widget.tagName == "bookmark"
              ? refreshBookmarkContents
              : () => refreshTagContents(widget.tagName)),
      child: FutureBuilder<ApiResponse<List<Content>>>(
        future: _futureContents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
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
            List<Content> contents = snapshot.data!.data ?? [];

            if (contents.isEmpty) {
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
            // 콘텐츠 인스턴스 띄우는 부분
            return ListView.builder(
              itemCount: contents.length + 1,
              itemBuilder: (BuildContext ctx, int idx) {
                if (idx == contents.length) {
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
                  instanceHeight: 150.0,
                  content: contents[idx],
                );
              },
            );
          }
        },
      ),
    );
  }
}
