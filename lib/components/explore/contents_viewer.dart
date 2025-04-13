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
  List<Article> articles = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();
  int offset = 0;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    fetchInitialArticles();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100.0 &&
          !isFetchingMore &&
          hasMore) {
        fetchMoreArticles();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ContentsViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryName != widget.categoryName) {
      offset = 0;
      articles.clear();
      hasMore = true;
      fetchInitialArticles();
    }
  }

  Future<void> fetchInitialArticles() async {
    setState(() => isLoading = true);
    final result = await fetchArticles(offset, limit);
    if (mounted) {
      setState(() {
        articles = result.data ?? [];
        offset += limit;
        hasMore = (result.data?.length ?? 0) == limit;
        isLoading = false;
      });
    }
  }

  Future<void> fetchMoreArticles() async {
    setState(() => isFetchingMore = true);
    final result = await fetchArticles(offset, limit);
    if (mounted) {
      setState(() {
        final newData = result.data ?? [];
        articles.addAll(newData);
        offset += newData.length;
        hasMore = newData.length == limit;
        isFetchingMore = false;
      });
    }
  }

  Future<ApiResponse<List<Article>>> fetchArticles(
      int offset, int limit) async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    if (widget.categoryName == "owned") {
      return fetchUserArticlesLimited(
        provider.loginResponse!["id"],
        limit,
        offset,
        provider.loginResponse!["access_token"],
      );
    }

    return fetchCategoryArticles(
      limit,
      offset,
      widget.categoryName,
      provider.loginResponse!["access_token"],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalText(
            localizeText: "explore_screen_contents",
            textSize: 13.0,
            isBold: true,
          ),
          const SizedBox(height: 10),
          if (isLoading)
            Column(
              children: List.generate(5, (_) {
                return Column(
                  children: [
                    const Divider(height: 0.5),
                    ArticleInstanceShimmer(isDarkMode: isDarkMode),
                  ],
                );
              }),
            )
          else if (articles.isEmpty)
            Center(
              child: GlobalText(
                localizeText: "content_widget_empty",
                textSize: 15.0,
                textColor: Colors.grey,
              ),
            )
          else
            SizedBox(
              height: MediaQuery.of(context).size.height - 200.0,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: articles.length + (isFetchingMore ? 1 : 0),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100.0),
                itemBuilder: (context, index) {
                  if (index < articles.length) {
                    return Column(
                      children: [
                        const Divider(height: 0.5),
                        ArticleInstance(article: articles[index]),
                      ],
                    );
                  } else {
                    return SizedBox(
                      height: 300.0,
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              const Divider(height: 0.5),
                              ArticleInstanceShimmer(isDarkMode: isDarkMode),
                            ],
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
