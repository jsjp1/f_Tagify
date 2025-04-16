import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  bool isLoading = true;
  bool isFetchingMore = false;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();
  int offset = 0;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TagifyProvider>(context, listen: false);
    fetchInitialArticles();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100.0 &&
          !isFetchingMore &&
          provider.hasMoreByCategory[widget.categoryName]!) {
        fetchMoreArticles();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ContentsViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryName != widget.categoryName) {
      offset = 0;
      hasMore = true;
      fetchInitialArticles();
    }
  }

  Future<void> fetchInitialArticles() async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    final existingArticles = provider.categoryArticlesMap[widget.categoryName];

    if (existingArticles != null && existingArticles.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);
    await provider.pvFetchArticlesLimited(widget.categoryName, isInitial: true);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMoreArticles() async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    setState(() => isFetchingMore = true);
    await provider.pvFetchArticlesLimited(widget.categoryName,
        isInitial: false);
    if (mounted) {
      setState(() {
        isFetchingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TagifyProvider>(context, listen: true);

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
          else if (provider.categoryArticlesMap[widget.categoryName] != null &&
              provider.categoryArticlesMap[widget.categoryName]!.isEmpty)
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
                itemCount:
                    provider.categoryArticlesMap[widget.categoryName]!.length +
                        (isFetchingMore ? 1 : 0),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100.0),
                itemBuilder: (context, index) {
                  if (index <
                      provider
                          .categoryArticlesMap[widget.categoryName]!.length) {
                    return Column(
                      children: [
                        const Divider(height: 0.5),
                        ArticleInstance(
                            article: provider.categoryArticlesMap[
                                widget.categoryName]![index]),
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
