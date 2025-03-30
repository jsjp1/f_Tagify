import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/contents/content_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/content_detail_screen.dart';
import 'package:tagify/components/contents/common.dart';

class ContentWidget extends StatefulWidget {
  final int? tagSelectedId;
  final String? tagSelectedName;
  final GlobalKey<ContentWidgetState>? key;

  const ContentWidget({this.key, this.tagSelectedId, this.tagSelectedName})
      : super(key: key);

  @override
  ContentWidgetState createState() => ContentWidgetState();
}

class ContentWidgetState extends State<ContentWidget> {
  bool isLoading = false;

  Future<List<Content>> fetchUserTagContents() async {
    final provider = context.read<TagifyProvider>();
    await provider.pvFetchUserTagContents(
        widget.tagSelectedId!, widget.tagSelectedName!);

    return provider.tagContentsMap[widget.tagSelectedName!] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final double widgetWidth = MediaQuery.of(context).size.width * 0.9;
    final provider = Provider.of<TagifyProvider>(context, listen: true);

    return (widget.tagSelectedName != null &&
            provider.tagContentsMap[widget.tagSelectedName] == null)
        ? FutureBuilder<List<Content>>(
            future: fetchUserTagContents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: GlobalText(
                    localizeText: "content_widget_error",
                    textSize: 15.0,
                    textColor: Colors.red,
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: GlobalText(
                    localizeText: "content_widget_empty",
                    textSize: 15.0,
                    textColor: Colors.grey,
                  ),
                );
              } else {
                return _buildContentList(snapshot.data!, widgetWidth);
              }
            },
          )
        : RefreshIndicator.adaptive(
            displacement: 10.0,
            onRefresh: () async {
              if (provider.currentTag == "all") {
                provider.pvFetchUserAllContents();
              } else if (provider.currentTag == "bookmark") {
                provider.pvFetchUserBookmarkedContents();
              }
              // TODO: tag contents별 refresh -> tag id get 구현하면 될듯
            },
            child: (provider.tagContentsMap[provider.currentTag] == null ||
                    provider.tagContentsMap[provider.currentTag]!.isEmpty)
                ? Padding(
                    padding: EdgeInsets.only(bottom: navigationBarHeight),
                    child: Center(
                      child: GlobalText(
                        localizeText: "content_widget_empty",
                        textSize: 15.0,
                        isBold: false,
                        textColor: Colors.grey,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  )
                : widget.tagSelectedName != null
                    ? _buildContentList(
                        provider.tagContentsMap[widget.tagSelectedName]!,
                        widgetWidth)
                    : _buildContentList(
                        provider.tagContentsMap[provider.currentTag]!,
                        widgetWidth),
          );
  }
}

Widget _buildContentList(List<Content> contents, double widgetWidth) {
  return ListView.builder(
    itemCount: contents.length + 1,
    itemBuilder: (BuildContext context, int idx) {
      if (idx == contents.length) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.center,
            height: 75.0,
            child: GlobalText(
              localizeText: "content_widget_end",
              textColor: Colors.grey,
              textSize: 15.0,
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContentDetailScreen(
                content: contents[idx],
              ),
            ),
          );
        },
        child: ContentInstance(
          instanceWidth: widgetWidth,
          instanceHeight: 135.0,
          content: contents[idx],
        ),
      );
    },
  );
}
