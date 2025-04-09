import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/article.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/components/common/shimmer.dart';
import 'package:tagify/components/explore/article_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class ContentsViewer extends StatefulWidget {
  final String categoryName;

  const ContentsViewer({super.key, required this.categoryName});

  @override
  ContentsViewerState createState() => ContentsViewerState();
}

class ContentsViewerState extends State<ContentsViewer> {
  late List<Article> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<ApiResponse<List<Article>>> fetchArticles() async {
    // categoryName에 따라 다른 api호출 -> global, popular, hot, upvote, newest, owned, random
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    if (widget.categoryName == "owned") {
      return fetchUserArticlesLimited(provider.loginResponse!["id"], 30, 0,
          provider.loginResponse!["access_token"]);
    }

    // owned에 해당하는 건 없음
    return fetchCategoryArticles(
        30, 0, widget.categoryName, provider.loginResponse!["access_token"]);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GlobalText(
              localizeText: "explore_screen_contents",
              textSize: 13.0,
              isBold: true,
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: FutureBuilder(
              future: fetchArticles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: List.generate(10, (index) {
                        return Column(
                          children: [
                            const Divider(height: 0.5),
                            ArticleInstanceShimmer(isDarkMode: isDarkMode),
                          ],
                        );
                      }),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: GlobalText(
                      localizeText: "content_widget_error",
                      textSize: 15.0,
                      textColor: Colors.red,
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return Center(
                    child: GlobalText(
                      localizeText: "content_widget_empty",
                      textSize: 15.0,
                      textColor: Colors.grey,
                    ),
                  );
                } else if (snapshot.hasData == true) {
                  final articles = snapshot.data!.data;

                  if (articles == null) return SizedBox.shrink();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: articles.length + 1,
                    itemBuilder: (context, index) {
                      if (index < articles.length) {
                        return Column(
                          children: [
                            const Divider(height: 0.5),
                            ArticleInstance(article: articles[index])
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            const Divider(height: 0.5),
                            SizedBox(height: 100.0),
                          ],
                        ); // TODO: limit설정 후 더 fetch해오는걸로
                      }
                    },
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
