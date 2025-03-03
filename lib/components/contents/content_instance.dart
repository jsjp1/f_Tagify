import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/provider.dart';

class ContentInstance extends StatefulWidget {
  final double instanceWidth;
  final double instanceHeight;
  final Content content;

  const ContentInstance({
    super.key,
    required this.instanceWidth,
    required this.instanceHeight,
    required this.content,
  });

  @override
  ContentInstanceState createState() => ContentInstanceState();
}

class ContentInstanceState extends State<ContentInstance> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TagifyProvider>(builder: (context, provider, child) {
      Content updatedContent = provider.contents.firstWhere(
        (c) => c.id == widget.content.id,
        orElse: () => widget.content,
      );

      return Padding(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
        child: Container(
          width: widget.instanceWidth,
          height: widget.instanceHeight,
          decoration: BoxDecoration(
            color: whiteBackgroundColor,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                  color: contentInstanceBoxShadowColor,
                  blurRadius: 5.0,
                  spreadRadius: 0.01,
                  offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              // 콘텐츠 컨테이너 타이틀 바
              SizedBox(
                height: widget.instanceHeight * (0.05),
              ),
              SizedBox(
                height: widget.instanceHeight * (0.25),
                child: Row(
                  children: [
                    SizedBox(width: 10.0),
                    // 왼쪽 아이콘 그룹
                    Row(
                      children: [
                        SizedBox(width: 5.0),
                        CachedNetworkImage(
                          imageUrl: updatedContent.favicon,
                          height: 17.0,
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                          errorWidget: (context, url, error) {
                            return SizedBox.shrink();
                          },
                        ),
                        updatedContent.favicon != ""
                            ? SizedBox(width: 7.0)
                            : SizedBox.shrink(),
                        SizedBox(
                          width: widget.instanceWidth * (0.68),
                          child: GlobalText(
                            localizeText: widget.content.title,
                            textSize: contentInstanceTitleFontSize,
                            isBold: true,
                            textColor: containerTitleColor,
                            overflow: TextOverflow.ellipsis,
                            localization: false,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 27.0,
                          height: 24.0,
                          child: IconButton(
                            highlightColor: Colors.transparent,
                            icon: Icon(updatedContent.bookmark
                                ? Icons.bookmark_sharp
                                : Icons.bookmark_outline_sharp),
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              await toggleBookmark(widget.content.id);
                              Provider.of<TagifyProvider>(context,
                                      listen: false)
                                  .fetchContents();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 27.0,
                          height: 24.0,
                          child: IconButton(
                            highlightColor: Colors.transparent,
                            icon: Icon(Icons.more_vert_sharp),
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              await showModalBottomSheet(
                                backgroundColor: whiteBackgroundColor,
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                builder: (BuildContext context) {
                                  return Wrap(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            5.0, 10.0, 10.0, 0.0),
                                        child: ListTile(
                                          leading: Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: Icon(Icons.edit),
                                          ),
                                          title: GlobalText(
                                            localizeText:
                                                "content_instance_edit",
                                            textSize: 17.0,
                                            isBold: true,
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // TODO: 수정 로직 추가
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            5.0, 10.0, 10.0, 0.0),
                                        child: ListTile(
                                          leading: Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: Icon(CupertinoIcons.delete,
                                                color: mainColor),
                                          ),
                                          title: GlobalText(
                                            localizeText:
                                                "content_instance_delete",
                                            textSize: 17.0,
                                            textColor: mainColor,
                                            isBold: true,
                                          ),
                                          onTap: () async {
                                            bool reallyDelete = false;
                                            Navigator.pop(context);

                                            // TODO: alert 창 분리?
                                            await showCupertinoDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoAlertDialog(
                                                  title: GlobalText(
                                                    localizeText:
                                                        'content_instance_really_delete_alert',
                                                    textSize: 20.0,
                                                    isBold: true,
                                                  ),
                                                  content: GlobalText(
                                                    localizeText:
                                                        'content_instance_really_delete_text',
                                                    textSize: 15.0,
                                                  ),
                                                  actions: <Widget>[
                                                    CupertinoDialogAction(
                                                      child: GlobalText(
                                                        localizeText:
                                                            'content_instance_really_delete_cancel',
                                                        textSize: 15.0,
                                                        textColor:
                                                            blackBackgroundColor,
                                                        localization: true,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        reallyDelete = false;
                                                        return;
                                                      },
                                                    ),
                                                    CupertinoDialogAction(
                                                      child: GlobalText(
                                                        localizeText:
                                                            'content_instance_really_delete_ok',
                                                        textSize: 15.0,
                                                        textColor: mainColor,
                                                        localization: true,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        reallyDelete = true;
                                                        return;
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (reallyDelete == false) {
                                              return;
                                            }

                                            ApiResponse<void> _ =
                                                await deleteContent(
                                                    widget.content.id);

                                            await provider.fetchContents();
                                            await provider.fetchTags();
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 100.0),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.0),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: widget.instanceWidth,
                height: widget.instanceHeight * (0.45),
                child: Stack(
                  children: [
                    // 컨테이너 상단 좌측 썸네일
                    Positioned(
                      left: 20.0,
                      top: 5.0,
                      height: widget.instanceHeight * (0.35),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: widget.content.thumbnail != ""
                              ? CachedNetworkImage(
                                  imageUrl: widget.content.thumbnail,
                                  fit: BoxFit.cover,
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                )
                              : Container(
                                  color: contentInstanceNoThumbnailColor,
                                  child: Center(
                                    child: Text(
                                      "🙂‍↔️",
                                      style: TextStyle(fontSize: 30.0),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: widget.instanceWidth * (0.4),
                      top: 5.0,
                      child: SizedBox(
                        width: widget.instanceWidth * (0.5),
                        height: widget.instanceHeight * (0.35),
                        child: SingleChildScrollView(
                          child: GlobalText(
                            localizeText: widget.content.description,
                            textSize: contentInstanceDescriptionFontSize,
                            localization: false,
                            textColor: contentInstanceDescriptionColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: widget.instanceHeight * (0.05)),
              Center(
                child: SizedBox(
                  height: widget.instanceHeight * (0.11),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.content.tags.length,
                      itemBuilder: (context, index) {
                        return TagContainer(
                          tagName: widget.content.tags[index],
                        );
                      },
                    ),
                  ),
                ),
              ),
              // SizedBox(height: widget.instanceHeight * (0.4)),
            ],
          ),
        ),
      );
    });
  }
}

class TagContainer extends StatelessWidget {
  final String tagName;

  const TagContainer({super.key, required this.tagName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: whiteBackgroundColor,
          border: Border.all(
            color: contentInstanceTagBorderColor,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 0.0),
            child: GlobalText(
              localizeText: tagName,
              textSize: 10.0,
              textColor: contentInstanceTagTextColor,
              isBold: true,
              localization: false,
            ),
          ),
        ),
      ),
    );
  }
}
