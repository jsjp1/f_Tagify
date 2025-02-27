import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/search_bar.dart';
import 'package:tagify/components/home/tag_bar.dart';
import 'package:tagify/components/contents/content_widget.dart';
import 'package:tagify/global.dart';
import 'package:tagify/components/home/notice_widget.dart';
import 'package:tagify/components/home/navigation_bar.dart';
import 'package:tagify/provider.dart';

class HomeScreen extends StatefulWidget {
  Map<String, dynamic> loginResponse;

  HomeScreen({super.key, required this.loginResponse});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ContentWidgetState> contentWidgetKey = GlobalKey<
      ContentWidgetState>(); // contentWidget의 refreshContents 다른 곳에서 사용하기 위해

  @override
  void initState() {
    super.initState();
    final TagifyProvider _provider =
        Provider.of<TagifyProvider>(context, listen: false);
    _provider.setUserId(widget.loginResponse["id"]);
    _provider.setUserInfo(widget.loginResponse);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      // login으로 넘어오는 경우
      widget.loginResponse = args;
      provider.setUserId(args["id"]);
      provider.setUserInfo(args);
    }
    debugPrint("home_screen.dart: loginResponse: $widget.loginResponse");

    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          color: noticeWidgetColor,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TagifyAppBar(),
                  Expanded(
                    child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                NoticeWidget(),
                                SearchBarWidget(),
                              ],
                            ),
                          ),
                          SliverPersistentHeader(
                            pinned: true,
                            floating: false,
                            delegate: _TagBarDelegate(
                              userId: provider.loginResponse!["id"],
                              contentWidgetKey: contentWidgetKey,
                            ),
                          ),
                        ];
                      },
                      body: ContentWidget(
                        key: contentWidgetKey,
                        userId: provider.loginResponse!["id"],
                      ),
                    ),
                  ),
                ],
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
    );
  }
}

class _TagBarDelegate extends SliverPersistentHeaderDelegate {
  final double tagBarHeight = 55.0;
  final int userId;
  final GlobalKey<ContentWidgetState> contentWidgetKey;

  _TagBarDelegate({
    required this.userId,
    required this.contentWidgetKey,
  });

  @override
  double get minExtent => tagBarHeight + 1.0; // DIVIDER 두께
  @override
  double get maxExtent => tagBarHeight + 1.0; // DIVIDER 두께

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return TagBar(
      userId: userId,
      contentWidgetKey: contentWidgetKey,
      tagBarHeight: tagBarHeight,
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
