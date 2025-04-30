import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/navigation_bar.dart';
import 'package:tagify/components/home/search_bar.dart';
import 'package:tagify/components/home/tag_bar.dart';
import 'package:tagify/components/contents/content_widget.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/settings_screen.dart';
import 'package:tagify/components/common/animated_drawer_layout.dart';
import 'package:tagify/components/common/tag_list_drawer.dart';
import 'package:tagify/utils/util.dart';

class HomeScreen extends StatefulWidget {
  Map<String, dynamic> loginResponse;

  HomeScreen({super.key, required this.loginResponse});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ContentWidgetState> contentWidgetKey = GlobalKey<
      ContentWidgetState>(); // contentWidget의 refreshContents 다른 곳에서 사용하기 위해
  final GlobalKey<AnimatedDrawerLayoutState> drawerLayoutKey =
      GlobalKey<AnimatedDrawerLayoutState>();

  AppLifecycleState? _lastState;

  @override
  void initState() {
    super.initState();
    final TagifyProvider provider =
        Provider.of<TagifyProvider>(context, listen: false);

    // 초기 세팅
    provider.setInitialSetting(widget.loginResponse);

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkSharedItems(context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_lastState == AppLifecycleState.inactive &&
        state == AppLifecycleState.resumed) {
      checkSharedItems(context);
    }
    _lastState = state;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      widget.loginResponse = args;

      provider.setInitialSetting(args);
    }
    debugPrint("home_screen.dart: loginResponse: ${widget.loginResponse}");

    return Scaffold(
      body: AnimatedDrawerLayout(
        key: drawerLayoutKey,
        mainContent: SafeArea(
          top: true,
          bottom: false,
          child: Container(
            color: isDarkMode ? darkNoticeWidgetColor : noticeWidgetColor,
            child: Stack(
              children: [
                Column(
                  children: [
                    TagifyAppBar(
                      onLogoImageTap: () {
                        drawerLayoutKey.currentState?.toggleLeftMenu();
                      },
                      onProfileTap: () {
                        drawerLayoutKey.currentState?.toggleRightMenu();
                      },
                    ),
                    Expanded(
                      child: NestedScrollView(
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  SearchBarWidget(),
                                ],
                              ),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              floating: false,
                              delegate: _TagBarDelegate(
                                userId: Provider.of<TagifyProvider>(context,
                                        listen: false)
                                    .loginResponse!["id"],
                                contentWidgetKey: contentWidgetKey,
                              ),
                            ),
                          ];
                        },
                        body: ContentWidget(
                          key: contentWidgetKey,
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
        leftDrawerContent: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                offset: Offset(5, 0),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TagListDrawer(
            drawerLayoutKey: drawerLayoutKey,
          ),
        ),
        rightDrawerContent: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                offset: Offset(-5, 0),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SettingsScreen(), // 기존 화면
        ),
      ),
    );
  }
}

class _TagBarDelegate extends SliverPersistentHeaderDelegate {
  final double tagBarHeight = 50.0;
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
