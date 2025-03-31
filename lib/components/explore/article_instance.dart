import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/screens/article_detail_screen.dart';
import 'package:tagify/utils/util.dart';

class ArticleInstance extends StatelessWidget {
  final Article article;
  late List<Content> contents;
  final PageController _pageController = PageController();

  ArticleInstance({super.key, required this.article}) {
    Map<String, dynamic> contentsMap =
        decodeBase64AndDecompress(article.encodedContent);

    contents = (contentsMap["contents"] as List<dynamic>)
        .map((item) => Content.fromJson(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? lightBlackBackgroundColor
                    : whiteBackgroundColor,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? darkContentInstanceBoxShadowColor
                        : contentInstanceBoxShadowColor,
                    blurRadius: 5.0,
                    spreadRadius: 0.01,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              width: double.infinity,
              height: 250.0,
              child: Column(
                children: [
                  // 썸네일 이미지 미리보기 부분
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: SizedBox(
                        height: 170.0,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // 썸네일 이미지 미리보기 넘기면서 보여주도록
                            PageView.builder(
                              controller: _pageController,
                              itemCount: contents.length,
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: contents[index].thumbnail,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return Container(color: Colors.grey);
                                  },
                                );
                              },
                            ),
                            // 현재 페이지를 표현하는 점
                            Positioned(
                              bottom: 8.0,
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: contents.length,
                                effect: ExpandingDotsEffect(
                                  dotHeight: 8.0,
                                  dotWidth: 8.0,
                                  activeDotColor: Colors.black,
                                  dotColor: Colors.blueGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 유저 프로필 이미지, 게시글 제목, 설명 등 표시
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              height: 20.0,
                              child: article.userProfileImage.isNotEmpty
                                  ? ClipOval(
                                      child: Image(
                                        image: CachedNetworkImageProvider(
                                          article.userProfileImage,
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : Icon(CupertinoIcons.person_crop_circle_fill,
                                      color: Colors.grey),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GlobalText(
                                  localizeText: article.title,
                                  textSize: 15.0,
                                  localization: false,
                                  isBold: true,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * (0.7),
                                  child: GlobalText(
                                    localizeText: article.body,
                                    textSize: 11.0,
                                    localization: false,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.0),
          ],
        ),
      ),
    );
  }
}
