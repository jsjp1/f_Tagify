import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/components/explore/article_edit_modal.dart';
import 'package:tagify/global.dart';
import 'package:tagify/utils/util.dart';

class ArticleInstanceAB extends StatelessWidget {
  final Article article;

  late List<String> thumbnails = [];

  ArticleInstanceAB({super.key, required this.article}) {
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
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
        child: Column(
          children: [
            // 작성자 프로필 이미지 및 title
            SizedBox(
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    SizedBox(
                      height: 15.0,
                      child: article.userProfileImage.isNotEmpty
                          ? ClipOval(
                              child: Image(
                                image: CachedNetworkImageProvider(
                                  article.userProfileImage,
                                ),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              CupertinoIcons.person_crop_circle_fill,
                              size: profileImageHeightInArticleWidget,
                              color: Colors.grey,
                            ),
                    ),
                    SizedBox(width: 7.0),
                    GlobalText(
                      localizeText: article.title,
                      textSize: 15.0,
                      isBold: true,
                      localization: false,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5.0),
            // body 부분
            SizedBox(
              height: articleInstanceHeight * (0.35),
              child: Align(
                alignment: Alignment.topLeft,
                child: GlobalText(
                  localizeText: article.body,
                  textSize: 12.0,
                  localization: false,
                ),
              ),
            ),
            SizedBox(height: 5.0),
            // Expanded(child: Container(color: Colors.black)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // // 다운로드 아이콘 + 숫자
                  // Row(
                  //   children: [
                  //     Icon(Icons.download, color: mainColor, size: 24.0),
                  //     SizedBox(width: 5.0),
                  //     Text("0",
                  //         style:
                  //             TextStyle(color: Colors.black, fontSize: 16.0)),
                  //   ],
                  // ),

                  // // 좋아요 아이콘 + 숫자
                  // Row(
                  //   children: [
                  //     Icon(Icons.favorite, color: Colors.red, size: 24.0),
                  //     SizedBox(width: 5.0),
                  //     Text("0",
                  //         style:
                  //             TextStyle(color: Colors.black, fontSize: 16.0)),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
