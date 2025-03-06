import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/contents/content_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/content_detail_screen.dart';

class ContentWidget extends StatefulWidget {
  final GlobalKey<ContentWidgetState>? key;

  const ContentWidget({this.key}) : super(key: key);

  @override
  ContentWidgetState createState() => ContentWidgetState();
}

class ContentWidgetState extends State<ContentWidget> {
  @override
  Widget build(BuildContext context) {
    final double widgetWidth = MediaQuery.of(context).size.width * (0.9);
    final provider = Provider.of<TagifyProvider>(context, listen: true);

    return RefreshIndicator.adaptive(
      displacement: 10.0,
      onRefresh: provider.fetchContents,
      child: provider.contents.isEmpty
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
          : ListView.builder(
              itemCount: provider.contents.length + 1,
              itemBuilder: (BuildContext ctx, int idx) {
                if (idx == provider.contents.length) {
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
                          content: provider.contents[idx],
                        ),
                      ),
                    );
                  },
                  child: ContentInstance(
                    instanceWidth: widgetWidth,
                    instanceHeight: 135.0,
                    content: provider.contents[idx],
                  ),
                );
              },
            ),
    );
  }
}
