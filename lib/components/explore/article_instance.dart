import 'package:flutter/material.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/global.dart';

class ArticleInstance extends StatelessWidget {
  final Article article;

  const ArticleInstance({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      child: Container(
        decoration: BoxDecoration(
            color: whiteBackgroundColor,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 10.0,
                spreadRadius: 1.0,
                offset: Offset(1, 5),
              ),
            ]),
        child: Column(
          children: [
            Text(article.title),
            Text(article.body),
            Text(article.encodedContent),
            Text(article.createdAt.toString()),
            Text(article.updatedAt.toString()),
            Text(article.upCount.toString()),
            Text(article.downCount.toString()),
          ],
        ),
      ),
    );
  }
}
