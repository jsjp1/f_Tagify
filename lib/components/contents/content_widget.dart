import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagify/components/common/delete_alert.dart';

import 'package:tagify/components/contents/content_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/content_detail_screen.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/utils/util.dart';

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
    final provider = Provider.of<TagifyProvider>(context, listen: false);
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
                return _buildContentList(context, snapshot.data!, widgetWidth);
              }
            },
          )
        : RefreshIndicator.adaptive(
            displacement: 3.0,
            onRefresh: () async {
              if (provider.currentTag == "all") {
                provider.pvFetchUserAllContents();
              } else if (provider.currentTag == "bookmark") {
                provider.pvFetchUserBookmarkedContents();
              }

              await checkSharedItems(context);
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
                        context,
                        provider.tagContentsMap[widget.tagSelectedName]!,
                        widgetWidth)
                    : _buildContentList(
                        context,
                        provider.tagContentsMap[provider.currentTag]!,
                        widgetWidth),
          );
  }
}

Widget _buildContentList(
    BuildContext context, List<Content> contents, double widgetWidth) {
  final provider = Provider.of<TagifyProvider>(context, listen: false);

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
        onLongPress: () async {
          // 길게 눌렀을 때 삭제창 뜨도록
          bool reallyDelete = false;
          String alertMessage = "content_instance_really_delete_text";
          reallyDelete = await showDeleteAlert(context, alertMessage);

          if (reallyDelete == false) {
            return;
          }

          await provider.pvDeleteUserContent(contents[idx].id);
        },
        onTap: () {
          Navigator.push(
            context,
            CustomPageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ContentDetailScreen(
                content: contents[idx],
              ),
            ),
          );
        },
        child: ContentInstance(
          instanceWidth: widgetWidth,
          instanceHeight: 140.0,
          content: contents[idx],
        ),
      );
    },
  );
}
