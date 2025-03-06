import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagify/components/common/animated_drawer_layout.dart';
import 'package:tagify/components/explore/search_bar.dart';

import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/navigation_bar_ab.dart';
import 'package:tagify/global.dart';
import 'package:tagify/components/explore/article_widget.dart';
import 'package:tagify/components/explore/upload_dialog.dart';
import 'package:tagify/screens/settings_screen.dart';

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
      backgroundColor: whiteBackgroundColor,
      body: AnimatedDrawerLayout(
        key: drawerLayoutKey,
        mainContent: SafeArea(
          top: true,
          bottom: false,
          child: Container(
            color: noticeWidgetColor,
            child: Stack(
              children: [
                Column(
                  children: [
                    TagifyAppBar(
                      onProfileTap: () {
                        drawerLayoutKey.currentState?.toggleMenu();
                      },
                    ),
                    // TODO: 검색 기능 (작성자, 게시물 이름)
                    // TODO: 카테고리 기능, 분류 기능 (추후)
                    ArticleSearchBar(),
                    const Divider(height: 0.0, thickness: 0.3),
                    const SizedBox(height: 10.0), // TODO: 자연스럽게
                    Expanded(child: ArticleWidget()),
                  ],
                ),
                Positioned(
                  bottom: navigationBarHeight + 20.0,
                  right: 20.0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(CircleBorder()),
                      padding: WidgetStateProperty.all(EdgeInsets.all(10.0)),
                      backgroundColor: WidgetStateProperty.all(mainColor),
                    ),
                    onPressed: () {
                      // TODO: UI 수정
                      exploreScreenUploadDialog(context);
                    },
                    child: Icon(
                      CupertinoIcons.arrow_up_doc,
                      size: 30.0,
                      color: whiteBackgroundColor,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: TagifyNavigationBar(),
                ),
              ],
            ),
          ),
        ),
        drawerContent: SettingsScreen(),
      ),
    );
  }
}
