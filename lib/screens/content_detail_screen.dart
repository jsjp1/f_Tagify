import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:tagify/components/common/delete_alert.dart';
import 'package:tagify/screens/content_edit_screen.dart';
import 'package:tagify/components/common/tag_container.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/screens/tag_detail_screen.dart';
import 'package:tagify/utils/util.dart';

class ContentDetailScreen extends StatefulWidget {
  final Content content;
  final bool? isArticleContent;

  const ContentDetailScreen(
      {super.key, required this.content, this.isArticleContent});

  @override
  ContentDetailScreenState createState() => ContentDetailScreenState();
}

class ContentDetailScreenState extends State<ContentDetailScreen> {
  late YoutubePlayerController _youtubeController;
  bool isDeleted = false;
  late bool _isVideo;
  late bool isMemo;

  @override
  void initState() {
    super.initState();

    String videoId = extractVideoId(widget.content.url);
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        forceHD: false,
      ),
    );

    _isVideo = isVideo(widget.content.url);
    isMemo = widget.content.url == "";
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double appBarHeight = AppBar().preferredSize.height;
    final double widgetWidget = MediaQuery.of(context).size.width * (0.9);
    final provider = Provider.of<TagifyProvider>(context, listen: true);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: appBarHeight),
              isMemo
                  ? const SizedBox(height: 60.0)
                  : AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _isVideo
                          ? YoutubePlayer(
                              controller: _youtubeController,
                              showVideoProgressIndicator: false,
                              progressIndicatorColor: mainColor,
                              bottomActions: [
                                CurrentPosition(),
                                ProgressBar(
                                  isExpanded: true,
                                  colors: ProgressBarColors(
                                    playedColor: mainColor,
                                    handleColor: mainColor,
                                    bufferedColor: Colors.grey,
                                    backgroundColor: Colors.black26,
                                  ),
                                ),
                                RemainingDuration(),
                              ],
                            )
                          : ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withAlpha(70),
                                BlendMode.darken,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: widget.content.thumbnail,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return Container(
                                      color: isDarkMode
                                          ? Colors.grey[700]
                                          : Colors.grey[100]);
                                },
                              ),
                            ),
                    ),
              // thumbnail 아래 컨텐츠 설명 나열 부분
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          widget.isArticleContent != null &&
                                  widget.isArticleContent! == true
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(5.0, 10.0, 0.0, 10.0),
                                  child: IconButton(
                                    highlightColor: Colors.transparent,
                                    icon: Icon(provider.bookmarkedSet
                                            .contains(widget.content.id)
                                        ? Icons.bookmark_sharp
                                        : Icons.bookmark_outline_sharp),
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      await provider
                                          .pvToggleBookmark(widget.content.id);
                                    },
                                  ),
                                ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  // padding: EdgeInsets.all(10.0),
                                  padding: EdgeInsets.fromLTRB(
                                      0.0, 10.0, 10.0, 10.0),
                                  child: GlobalText(
                                    localizeText: widget.content.title,
                                    textSize: 20.0,
                                    isBold: true,
                                    overflow: TextOverflow.ellipsis,
                                    localization: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: SizedBox(
                          width: widgetWidget,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30.0),
                              GlobalText(
                                localizeText:
                                    "content_detail_screen_description",
                                textSize: 17.0,
                                textColor: Colors.grey,
                                localization: true,
                              ),
                              const SizedBox(height: 17.0),
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: GlobalText(
                                  localizeText: widget.content.description,
                                  textSize: 13.0,
                                  localization: false,
                                ),
                              ),
                              const SizedBox(height: 30.0),
                              GlobalText(
                                localizeText: "content_detail_screen_tags",
                                textSize: 17.0,
                                textColor: Colors.grey,
                                localization: true,
                              ),
                              const SizedBox(height: 17.0),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(
                                    widget.content.tags.length,
                                    (index) {
                                      return TagContainer(
                                        tagName: widget.content.tags[index],
                                        textSize: 13.0,
                                        isLastButton: true,
                                        tagColor: isDarkMode
                                            ? darkContentInstanceTagTextColor
                                            : contentInstanceTagTextColor,
                                        onTap: widget.isArticleContent !=
                                                    null &&
                                                widget.isArticleContent! == true
                                            ? () {}
                                            : () {
                                                Navigator.push(context,
                                                    CustomPageRouteBuilder(
                                                        pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) {
                                                  Tag tag = provider.tags
                                                      .firstWhere((item) =>
                                                          item.tagName ==
                                                          widget.content
                                                              .tags[index]);

                                                  return TagDetailScreen(
                                                      tag: tag);
                                                }));
                                              },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 30.0),
                                child: GlobalText(
                                  localizeText: widget.content.createdAt,
                                  textSize: 12.0,
                                  textColor: Colors.grey,
                                  localization: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 200.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 뒤로가기 버튼
          Positioned(
            left: 0.0,
            top: appBarHeight + 5.0,
            child: IconButton(
              icon: Icon(CupertinoIcons.back,
                  color: isMemo
                      ? (isDarkMode
                          ? whiteBackgroundColor
                          : lightBlackBackgroundColor)
                      : whiteBackgroundColor),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // 컨텐츠 수정 / 삭제 / ... 버튼
          (widget.isArticleContent == null || widget.isArticleContent! == false)
              ? Positioned(
                  right: 0.0,
                  top: appBarHeight + 5.0,
                  child: IconButton(
                    icon: Icon(Icons.more_vert_sharp,
                        color: isMemo
                            ? (isDarkMode
                                ? whiteBackgroundColor
                                : lightBlackBackgroundColor)
                            : whiteBackgroundColor),
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (BuildContext context) {
                          return Wrap(
                            children: [
                              widget.content.url != ""
                                  ? Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 10.0, 10.0, 0.0),
                                      child: ListTile(
                                        leading: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Icon(Icons.copy),
                                        ),
                                        title: GlobalText(
                                          localizeText:
                                              "content_instance_copy_url",
                                          textSize: 17.0,
                                          isBold: true,
                                        ),
                                        onTap: () async {
                                          Navigator.pop(context);

                                          await Clipboard.setData(
                                            ClipboardData(
                                                text: widget.content.url),
                                          );

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              duration: Duration(seconds: 1),
                                              backgroundColor: snackBarColor,
                                              content: GlobalText(
                                                localizeText:
                                                    "content_instance_url_copy_success",
                                                textSize: 15.0,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 0.0),
                                child: ListTile(
                                  leading: Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Icon(Icons.edit),
                                  ),
                                  title: GlobalText(
                                    localizeText: "content_instance_edit",
                                    textSize: 17.0,
                                    isBold: true,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      CustomPageRouteBuilder(
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) {
                                          return ContentEditScreen(
                                              content: widget.content);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 0.0),
                                child: ListTile(
                                  leading: Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Icon(CupertinoIcons.delete,
                                        color: mainColor),
                                  ),
                                  title: GlobalText(
                                    localizeText: "content_instance_delete",
                                    textSize: 17.0,
                                    textColor: mainColor,
                                    isBold: true,
                                  ),
                                  onTap: () async {
                                    bool reallyDelete = false;

                                    String alertMessage =
                                        "content_instance_really_delete_text";
                                    reallyDelete = await showDeleteAlert(
                                        context, alertMessage);

                                    if (reallyDelete == false) {
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                      return;
                                    }

                                    await provider
                                        .pvDeleteUserContent(widget.content.id);

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                    isDeleted = true;
                                  },
                                ),
                              ),
                              SizedBox(height: 100.0),
                            ],
                          );
                        },
                      );
                      // 삭제 후 content widget 페이지로 이동
                      if (isDeleted == true) Navigator.pop(context);
                    },
                  ),
                )
              : const SizedBox.shrink(),
          // 컨텐츠 원문보기 버튼
          // 메모로 저장되지 않았다면 버튼 표시
          widget.content.url != ""
              ? Positioned(
                  bottom: 15.0,
                  child: GestureDetector(
                    onTap: () => launchContentUrl(widget.content.url),
                    child: SizedBox(
                      height: 70.0,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Container(
                          height: 60.0,
                          width: MediaQuery.of(context).size.width * (0.85),
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Center(
                            child: GlobalText(
                              localizeText:
                                  "content_detail_screen_move_to_content_button_text",
                              textSize: 20.0,
                              textColor: whiteBackgroundColor,
                              localization: true,
                              isBold: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
