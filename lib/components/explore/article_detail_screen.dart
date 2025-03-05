import 'package:flutter/material.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/global.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}
