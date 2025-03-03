import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/explore/article_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class ArticleWidget extends StatefulWidget {
  const ArticleWidget({super.key});

  @override
  ArticleWidgetState createState() => ArticleWidgetState();
}

class ArticleWidgetState extends State<ArticleWidget> {
  @override
  void initState() {
    super.initState();

    final provider = Provider.of<TagifyProvider>(context, listen: false);
    provider.fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: Consumer<TagifyProvider>(
        builder: (context, provider, child) {
          final articles = provider.articles;

          if (articles == []) {
            return Center(child: CircularProgressIndicator());
          } else if (articles.isEmpty) {
            return Center(
              child: GlobalText(
                localizeText: "article_widget_empty",
                textSize: 15.0,
                isBold: false,
                textColor: Colors.grey,
                overflow: TextOverflow.clip,
              ),
            );
          }

          return RefreshIndicator.adaptive(
            displacement: 0.0,
            onRefresh: () async => await provider.fetchArticles(),
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final Article article = articles[index];

                return ArticleInstance(article: article);
              },
            ),
          );
        },
      ),
    );
  }
}
