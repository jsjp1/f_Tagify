import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/navigation_bar.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/settings_screen.dart';
import 'package:tagify/components/common/animated_drawer_layout.dart';
import 'package:tagify/components/common/tag_list_drawer.dart';
import 'package:tagify/screens/tag_detail_screen.dart';

class TagScreen extends StatefulWidget {
  const TagScreen({super.key});

  @override
  TagScreenState createState() => TagScreenState();
}

class TagScreenState extends State<TagScreen> {
  final GlobalKey<AnimatedDrawerLayoutState> drawerLayoutKey =
      GlobalKey<AnimatedDrawerLayoutState>();

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    Divider(
                      thickness: 0.3,
                      height: 0.0,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Consumer<TagifyProvider>(
                          builder: (context, provider, child) {
                            return TagGridView();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 83.0),
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

class TagGridView extends StatelessWidget {
  const TagGridView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final provider = Provider.of<TagifyProvider>(context, listen: true);
    final tags = provider.tags;
    final List<List<Content>> tagContents =
        tags.map((item) => provider.tagContentsMap[item.tagName]!).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1,
      ),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final Tag _tag = tags[index];
        final List<Content> _tagContents = tagContents[index];

        return Container(
          margin: const EdgeInsets.fromLTRB(5.0, 12.0, 5.0, 0.0),
          child: PhysicalModel(
            color: Colors.transparent,
            elevation: 4,
            borderRadius: BorderRadius.circular(20.0),
            child: GestureDetector(
              onLongPress: () {
                debugPrint("TEST"); // TODO
              },
              onTap: () async {
                await Navigator.push(
                  context,
                  CustomPageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          TagDetailScreen(tag: tags[index])),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? lightBlackBackgroundColor
                      : whiteBackgroundColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      GlobalText(
                        localizeText: _tag.tagName,
                        textSize: 14.0,
                        overflow: TextOverflow.ellipsis,
                        isBold: true,
                        localization: false,
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                            childAspectRatio: 1,
                          ),
                          itemCount:
                              _tagContents.length > 6 ? 6 : _tagContents.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                imageUrl: _tagContents[index].thumbnail,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
