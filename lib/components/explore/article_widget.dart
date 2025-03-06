import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/explore/article_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/screens/article_detail_screen.dart';
import 'package:tagify/provider.dart';

class ArticleWidget extends StatefulWidget {
  const ArticleWidget({super.key});

  @override
  ArticleWidgetState createState() => ArticleWidgetState();
}

class ArticleWidgetState extends State<ArticleWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    if (provider.hasMoreArticles == false) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreArticles();
    }
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<TagifyProvider>(context, listen: false);
    await provider.fetchOldArticles();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TagifyProvider>(
      builder: (context, provider, child) {
        final articles = provider.articles;

        if (articles.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(bottom: navigationBarHeight),
            child: Center(
              child: GlobalText(
                localizeText: "content_widget_empty",
                textSize: 15.0,
                isBold: false,
                textColor: Colors.grey,
                overflow: TextOverflow.clip,
              ),
            ),
          );
        }

        return RefreshIndicator.adaptive(
          displacement: 1.0,
          onRefresh: () async => await provider.fetchArticles(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: articles.length + 1,
            itemBuilder: (context, index) {
              if (index == articles.length) {
                return _isLoading
                    ? const SizedBox(height: 60.0)
                    : Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          alignment: Alignment.center,
                          height: 75.0,
                          child: GlobalText(
                            localizeText: "article_widget_no_more_article",
                            textColor: Colors.grey,
                            textSize: 15.0,
                            localization: true,
                          ),
                        ),
                      );
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ArticleDetailScreen(article: articles[index]),
                    ),
                  );
                },
                child: ArticleInstance(
                  article: articles[index],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
