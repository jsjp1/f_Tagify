import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/components/explore/article_edit_modal.dart';
import 'package:tagify/global.dart';
import 'package:tagify/utils/util.dart';

class ArticleInstance extends StatelessWidget {
  final Article article;

  late List<String> thumbnails = [];

  ArticleInstance({super.key, required this.article}) {
    Map<String, dynamic> contentsMap =
        decodeBase64AndDecompress(article.encodedContent);

    List<Content> contents = (contentsMap["contents"] as List<dynamic>)
        .map((item) => Content.fromJson(item))
        .toList();

    for (int i = 0; i < contents.length && i < 3; ++i) {
      thumbnails.add(contents[i].thumbnail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: articleInstanceHeight,
      decoration: BoxDecoration(
        color: whiteBackgroundColor,
        borderRadius: BorderRadius.circular(0.0),
        border: Border.all(
          color: Colors.grey,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: contentInstanceBoxShadowColor,
            blurRadius: 5.0,
            spreadRadius: 0.01,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 작성자 프로필 이미지 및 title
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {}, // TODO: 작성자 정보
                child: Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Container(
                    width: profileImageHeightInArticle,
                    height: profileImageHeightInArticle,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
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
                            size: profileImageHeightInArticle,
                            color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * (0.645),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlobalText(
                        localizeText: article.title,
                        textSize: 17.0,
                        isBold: true,
                        overflow: TextOverflow.ellipsis,
                        localization: false,
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
              IconButton(
                icon: Icon(Icons.more_vert_sharp),
                padding: EdgeInsets.zero,
                onPressed: () {
                  articleInstanceEditBottomModal(context, article);
                },
              ),
            ],
          ),
          // 콘텐츠 미리보기 이미지
          SizedBox(
            height: articleInstanceHeight * (0.5),
            child: Stack(
              children: [
                for (int i = thumbnails.length - 1; i >= 0; --i)
                  Positioned(
                    left: 15.0 + i * 20.0,
                    top: 5.0 + i * 3.0,
                    child: Container(
                      height: articleInstanceHeight * (0.45 - i * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(width: 0.3, color: Colors.grey),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: i * 1.0,
                            sigmaY: i * 1.0,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: thumbnails[i],
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            placeholder: (context, url) {
                              return Container(
                                color: contentInstanceNoThumbnailColor,
                                child: Center(
                                  child: Text(
                                    "🙂‍↔️",
                                    style: TextStyle(fontSize: 30.0),
                                  ),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Container(
                                color: contentInstanceNoThumbnailColor,
                                child: Center(
                                  child: Text(
                                    "🙂‍↔️",
                                    style: TextStyle(fontSize: 30.0),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 게시물 작성 시각 및 상호작용 버튼
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      GlobalText(
                        localizeText: "article_instance_created_at_text",
                        textSize: 8.0,
                        textColor: Colors.grey,
                        localization: true,
                      ),
                      GlobalText(
                        localizeText: "  ${datetimeToYMD(article.createdAt)}",
                        textSize: 8.0,
                        isBold: false,
                        textColor: Colors.grey,
                        localization: false,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child:
                            Icon(CupertinoIcons.arrowtriangle_up, size: 13.0),
                      ),
                      SizedBox(width: 5),
                      GlobalText(
                        localizeText: article.upCount.toString(),
                        textSize: 13.0,
                        localization: false,
                        textColor: Colors.grey,
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {},
                        child:
                            Icon(CupertinoIcons.arrowtriangle_down, size: 13.0),
                      ),
                      SizedBox(width: 5),
                      GlobalText(
                        localizeText: article.downCount.toString(),
                        textSize: 13.0,
                        localization: false,
                        textColor: Colors.grey,
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {},
                        child:
                            Icon(CupertinoIcons.chat_bubble_text, size: 13.0),
                      ),
                      SizedBox(width: 5),
                      GlobalText(
                        localizeText: "test",
                        // article.commentCount.toString()
                        textSize: 13.0,
                        localization: false,
                        textColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
