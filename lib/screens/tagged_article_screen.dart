import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/article.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/components/common/shimmer.dart';
import 'package:tagify/components/explore/app_bar.dart';
import 'package:tagify/components/explore/article_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/article_upload_screen.dart';

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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                TagifyExploreAppBar(appBarName: widget.tagName),
                Expanded(
                  child: Container(
                    color:
                        isDarkMode ? darkNoticeWidgetColor : noticeWidgetColor,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
                      child: FutureBuilder(
                        future: _articlesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // TODO: 로딩되기전까지 동일한 크기의 placeholder 보여주기
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: List.generate(11, (index) {
                                    return Column(
                                      children: [
                                        ArticleInstanceShimmer(
                                            isDarkMode: isDarkMode),
                                        const Divider(height: 0.5),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: GlobalText(
                                localizeText: "content_widget_error", // TODO
                                textSize: 15.0,
                                textColor: Colors.red,
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
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
                                return Column(
                                  children: [
                                    ArticleInstance(article: articles[index]),
                                    const Divider(height: 0.5),
                                  ],
                                );
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
            // 여기서는 현재 위치한 tag가 자동으로 삽입됨
            Positioned(
              right: 35.0,
              bottom: 35.0,
              child: Container(
                decoration: BoxDecoration(
                  color: mainColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.upload, color: whiteBackgroundColor),
                  iconSize: 35.0,
                  onPressed: () async {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            UploadArticleScreen(
                                tagGiven:
                                    widget.tagId == -1 ? null : widget.tagName),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
