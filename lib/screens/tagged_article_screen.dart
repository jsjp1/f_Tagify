import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:tagify/api/article.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/components/explore/app_bar.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/article_detail_screen.dart';
import 'package:tagify/utils/util.dart';

class TaggedArticleScreen extends StatefulWidget {
  final int tagId;
  final String tagName;

  const TaggedArticleScreen(
      {super.key, required this.tagId, required this.tagName});

  @override
  TaggedArticleScreenState createState() => TaggedArticleScreenState();
}

class TaggedArticleScreenState extends State<TaggedArticleScreen> {
  late Future<List<Article>> _articlesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.tagId == -1) {
      _articlesFuture = fetchArticles();
    } else {
      _articlesFuture = fetchTaggedArticles();
    }
  }

  Future<List<Article>> fetchArticles() async {
    final provider = Provider.of<TagifyProvider>(context);
    ApiResponse<List<Article>> a = await fetchArticlesLimited(
      30, // TODO: limit, offset 바꾸기
      0,
      provider.loginResponse!["access_token"],
    );

    if (a.success) {
      return a.data!;
    }
    return [];
  }

  Future<List<Article>> fetchTaggedArticles() async {
    final provider = Provider.of<TagifyProvider>(context);
    ApiResponse<List<Article>> a = await fetchTaggedArticlesLimited(
      widget.tagId,
      30, // TODO: limit, offset 바꾸기
      0,
      provider.loginResponse!["access_token"],
    );

    if (a.success) {
      return a.data!;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            TagifyExploreAppBar(appBarName: widget.tagName),
            Expanded(
              child: Container(
                color: noticeWidgetColor,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                  child: FutureBuilder(
                    future: _articlesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // 로딩되기전까지 동일한 크기의 placeholder 보여주기
                        return ListView.builder(
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: contentInstanceBoxShadowColor,
                                      blurRadius: 5.0,
                                      spreadRadius: 0.01,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                height: 250.0,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        child: SizedBox(
                                          height: 170.0,
                                          child: Container(
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 3.0),
                                        child: Row(
                                          children: [
                                            Align(
                                              alignment: Alignment.topCenter,
                                              child: SizedBox(
                                                height: 20.0,
                                                child: Icon(
                                                  CupertinoIcons
                                                      .person_crop_circle_fill,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    color: Colors.grey[300],
                                                    height: 15.0,
                                                    width: 150.0,
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Container(
                                                    color: Colors.grey[300],
                                                    height: 11.0,
                                                    width: 100.0,
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
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: GlobalText(
                            localizeText: "content_widget_error", // TODO
                            textSize: 15.0,
                            textColor: Colors.red,
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: GlobalText(
                            localizeText: "content_widget_empty", // TODO
                            textSize: 15.0,
                            textColor: Colors.grey,
                          ),
                        );
                      } else {
                        final List<Article> articles = snapshot.data!;

                        return ListView.builder(
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            return ArticleContainer(article: articles[index]);
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleContainer extends StatelessWidget {
  final Article article;
  late List<Content> contents;
  final PageController _pageController = PageController();

  ArticleContainer({super.key, required this.article}) {
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
                color: whiteBackgroundColor,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: contentInstanceBoxShadowColor,
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
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GlobalText(
                                    localizeText: article.body,
                                    textSize: 11.0,
                                    localization: false,
                                    overflow: TextOverflow.ellipsis,
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
