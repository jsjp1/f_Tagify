import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/common/tag_container.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/components/explore/article_edit_modal.dart';
import 'package:tagify/global.dart';
import 'package:tagify/screens/article_detail_screen.dart';
import 'package:tagify/utils/smart_network_image.dart';
import 'package:tagify/utils/util.dart';

class ArticleInstance extends StatelessWidget {
  // TODO: 위젯 레이아웃 구성하는 것들 재구성 필요...
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CustomPageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return ArticleDetailScreen(article: article);
            },
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
        child: SizedBox(
          height: articleInstanceThumbnailHeight,
          child: Row(
            children: [
              // article 썸네일 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  height: articleInstanceThumbnailHeight,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: contents.length,
                          itemBuilder: (context, index) {
                            return SmartNetworkImage(
                              url: contents[index].thumbnail,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  Container(color: Colors.grey),
                            );
                          },
                        ),
                        // 현재 페이지를 표현하는 점
                        Positioned(
                          bottom: 6.0,
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: contents.length,
                            effect: ExpandingDotsEffect(
                              dotHeight: 4.0,
                              dotWidth: 4.0,
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
              // 사용자 이미지, 제목, 설명 등...
              // 이 부분 터치 시 ArticleDetailScreen으로
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 3.0, 0.0, 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: profileImageHeightInArticle,
                            child: article.userProfileImage.isNotEmpty
                                ? ClipOval(
                                    child: Image(
                                      image: CachedNetworkImageProvider(
                                        article.userProfileImage,
                                      ),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  )
                                : Icon(
                                    CupertinoIcons.person_crop_circle_fill,
                                    size: profileImageHeightInArticle,
                                    color: Colors.grey,
                                  ),
                          ),
                          const SizedBox(width: 5.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GlobalText(
                                localizeText: article.title,
                                textSize: 14.0,
                                localization: false,
                                overflow: TextOverflow.ellipsis,
                                isBold: true,
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * (0.41),
                                child: GlobalText(
                                  localizeText: article.body,
                                  textSize: 12.0,
                                  localization: false,
                                  overflow: TextOverflow.ellipsis,
                                  isBold: false,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    article.tags.length,
                                    (index) => TagContainer(
                                      tagName: article.tags[index],
                                      textSize: 9.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          articleInstanceEditBottomModal(context, article);
                        },
                        child: Icon(Icons.more_vert_outlined),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArticleInstancePlaceholder extends StatelessWidget {
  const ArticleInstancePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: SizedBox(
        height: articleInstanceThumbnailHeight,
        child: Row(
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: SizedBox(
                height: articleInstanceThumbnailHeight,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: darkNoticeWidgetColor),
                ),
              ),
            ),
            SizedBox(width: 10),
            // 오른쪽 텍스트 자리
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14.0,
                    color: darkNoticeWidgetColor,
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 12.0,
                    color: darkNoticeWidgetColor,
                  ),
                  Spacer(),
                  Row(
                    children: List.generate(
                      3,
                      (_) => Container(
                        margin: EdgeInsets.only(right: 6),
                        width: 30,
                        height: 14,
                        color: darkNoticeWidgetColor,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
