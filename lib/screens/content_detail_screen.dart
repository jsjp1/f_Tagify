import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagify/api/common.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/utils/util.dart';
import 'package:tagify/components/analyze/content_edit_widget.dart';

class ContentDetailScreen extends StatefulWidget {
  const ContentDetailScreen({super.key});

  @override
  ContentDetailScreenState createState() => ContentDetailScreenState();
}

class ContentDetailScreenState extends State<ContentDetailScreen> {
  Content? content;
  late YoutubePlayerController _youtubeController;
  bool isBookmarked = false;
  bool isDeleted = false;

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Content) {
      content = args;

      isBookmarked = content!.bookmark;

      String videoId = extractVideoId(content?.url ?? "");

      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          forceHD: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = AppBar().preferredSize.height;
    final double widgetWidget = MediaQuery.of(context).size.width * (0.9);
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: appBarHeight),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: content?.runtimeType.toString() == "Video"
                    ? YoutubePlayer(
                        controller: _youtubeController,
                        showVideoProgressIndicator: false,
                        progressColors: ProgressBarColors(
                          handleColor: mainColor,
                          playedColor: mainColor,
                        ),
                      )
                    : content?.thumbnail == ""
                        ? Container(color: Colors.grey)
                        : CachedNetworkImage(
                            imageUrl: content!.thumbnail,
                            fit: BoxFit.cover,
                          ), // TODO: 썸네일 없을 경우 기본 이미지 처리
              ),
              // thumbnail 아래 콘텐츠 설명 나열 부분
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                            child: IconButton(
                              highlightColor: Colors.transparent,
                              icon: Icon(isBookmarked
                                  ? Icons.bookmark_sharp
                                  : Icons.bookmark_outline_sharp),
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                setState(() {
                                  isBookmarked = !isBookmarked;
                                });

                                await toggleBookmark(content!.id);
                                Provider.of<TagifyProvider>(context,
                                        listen: false)
                                    .fetchContents();
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * (0.85),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: GlobalText(
                                      localizeText: content?.title ?? "",
                                      textSize: 20.0,
                                      isBold: true,
                                      overflow: TextOverflow.ellipsis,
                                      localization: false,
                                    ),
                                  ),
                                ],
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
                              GlobalText(
                                localizeText: content!.description,
                                textSize: 13.0,
                                localization: false,
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
                                    content!.tags.length,
                                    (index) {
                                      return TagContainer(
                                        tagName: content!.tags[index],
                                        onPressed: () {},
                                        isLastButton: true,
                                      );
                                    },
                                  ),
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
              icon: Icon(CupertinoIcons.back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // 콘텐츠 수정 / 삭제 / ... 버튼
          Positioned(
            right: 0.0,
            top: appBarHeight + 5.0,
            child: IconButton(
              icon: Icon(Icons.more_vert_sharp),
              padding: EdgeInsets.zero,
              onPressed: () async {
                await showModalBottomSheet(
                  backgroundColor: whiteBackgroundColor,
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (BuildContext context) {
                    return Wrap(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 0.0),
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
                              // TODO: 수정 로직 추가
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 0.0),
                          child: ListTile(
                            leading: Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child:
                                  Icon(CupertinoIcons.delete, color: mainColor),
                            ),
                            title: GlobalText(
                              localizeText: "content_instance_delete",
                              textSize: 17.0,
                              textColor: mainColor,
                              isBold: true,
                            ),
                            onTap: () async {
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
                                          textColor: blackBackgroundColor,
                                          localization: true,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          isDeleted = false;
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
                                          Navigator.of(context).pop();
                                          isDeleted = true;
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (isDeleted == false) {
                                return;
                              }

                              ApiResponse<void> _ =
                                  await deleteContent(content!.id);

                              await provider.fetchContents();
                              await provider.fetchTags();

                              // 삭제 모달 pop
                              Navigator.pop(context);
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
          ),
          // 콘텐츠 원문보기 버튼
          Positioned(
            bottom: 30.0,
            left: 20.0,
            right: 20.0,
            child: GestureDetector(
              onTap: () => launchContentUrl(content?.url ?? ""),
              child: Container(
                height: 60.0,
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(20.0),
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
        ],
      ),
    );
  }
}
