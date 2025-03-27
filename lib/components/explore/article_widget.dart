import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/explore/article_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/article_detail_screen.dart';

class ArticleWidget extends StatefulWidget {
  const ArticleWidget({super.key});

  @override
  ArticleWidgetState createState() => ArticleWidgetState();
}

class ArticleWidgetState extends State<ArticleWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context);

    return RefreshIndicator.adaptive(
      displacement: 1.0,
      onRefresh: () async {
        await provider.pvFetchRefreshedArticles();
      },
      child: ArticleList(),
    );
  }
}

class ArticleList extends StatelessWidget {
  const ArticleList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return ListView.builder(
      itemCount: provider.articles.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.articles.length) {
          return _buildNoMoreArticlesMessage();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ArticleDetailScreen(article: provider.articles[index]),
              ),
            );
          },
          child: ArticleInstance(article: provider.articles[index]),
        );
      },
    );
  }
}

Widget _buildNoMoreArticlesMessage() {
  return Align(
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
