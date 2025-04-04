import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/components/explore/article_edit_modal.dart';
import 'package:tagify/global.dart';
import 'package:tagify/screens/content_detail_screen.dart';
import 'package:tagify/utils/util.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  late List<Content> contents;

  ArticleDetailScreen({super.key, required this.article}) {
    // encoded content를 decode
    Map<String, dynamic> contentsMap =
        decodeBase64AndDecompress(article.encodedContent);

    contents = (contentsMap["contents"] as List<dynamic>)
        .map((item) => Content.fromJson(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final double widgetWidth = MediaQuery.of(context).size.width * (0.95);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              articleInstanceEditBottomModal(context, article);
            },
            icon: Icon(Icons.more_vert_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: true,
        child: Center(
          child: Column(
            children: [
              // 작성자 정보, 제목, 본문 부분
              SizedBox(
                width: widgetWidth,
                height: 300.0, // TODO
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: SizedBox(
                            width: profileImageHeightInArticleDetail,
                            height: profileImageHeightInArticleDetail,
                            child: article.userProfileImage.isNotEmpty
                                ? ClipOval(
                                    child: Image(
                                      image: CachedNetworkImageProvider(
                                        article.userProfileImage,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(CupertinoIcons.person_crop_circle_fill,
                                    size: profileImageHeightInArticleDetail,
                                    color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * (0.8),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: GlobalText(
                                    localizeText: article.title,
                                    textSize: 23.0,
                                    isBold: true,
                                    overflow: TextOverflow.ellipsis,
                                    localization: false,
                                  ),
                                ),
                                GlobalText(
                                  localizeText: article.userName,
                                  textSize: 10.0,
                                  textColor: Colors.grey,
                                  isBold: false,
                                  overflow: TextOverflow.ellipsis,
                                  localization: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: GlobalText(
                          localizeText: article.body,
                          textSize: 15.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 컨텐츠 썸네일 부분
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: articleDetailScreenThumbnailsHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // 컨텐츠 나열 부분 (좌우 스크롤)
                    child: Row(
                      children: contents.map((content) {
                        return SizedBox(
                          height: articleDetailScreenThumbnailsHeight * (0.9),
                          width: articleDetailScreenContentHeight * (16 / 9),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            // 컨텐츠 썸네일과 제목
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ContentDetailScreen(content: content),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: articleDetailScreenContentHeight,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                    // 컨텐츠 썸네일
                                    child: ClipRRect(
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: CachedNetworkImage(
                                          imageUrl: content.thumbnail,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) {
                                            return Container(
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 컨텐츠 제목
                                  Expanded(
                                    child: GlobalText(
                                      localizeText: content.title,
                                      textSize: 13.0,
                                      overflow: TextOverflow.ellipsis,
                                      localization: false,
                                      isBold: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const Divider(
                color: noticeWidgetColor,
                height: 0.0,
                thickness: 1.0,
              ),
              // 댓글 부분
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Wrap(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
