import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/navigation_bar_ab.dart';
import 'package:tagify/global.dart';
import 'package:tagify/components/explore/article_widget.dart';
import 'package:tagify/components/explore/upload_dialog.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/settings_screen.dart';
import 'package:tagify/components/common/animated_drawer_layout.dart';
import 'package:tagify/components/common/tag_list_drawer.dart';
import 'package:tagify/components/explore/search_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  final GlobalKey<AnimatedDrawerLayoutState> drawerLayoutKey =
      GlobalKey<AnimatedDrawerLayoutState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noticeWidgetColor,
      appBar: AppBar(
        // TODO: localization
        title: GlobalText(
          localizeText: "Explore",
          textSize: 25.0,
          isBold: true,
          localization: true,
        ),
        backgroundColor: whiteBackgroundColor,
      ),
      body: Stack(
        children: [
          ArticleWidget(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TagifyNavigationBar(),
          ),
        ],
      ),
    );
  }
}
