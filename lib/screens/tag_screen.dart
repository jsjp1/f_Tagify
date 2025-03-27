import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/navigation_bar_ab.dart';
import 'package:tagify/components/tag/tag_box_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/components/analyze/new_tag_modal.dart';
import 'package:tagify/screens/settings_screen.dart';
import 'package:tagify/screens/tag_detail_screen.dart';
import 'package:tagify/components/common/animated_drawer_layout.dart';
import 'package:tagify/components/common/tag_list_drawer.dart';

class TagScreen extends StatelessWidget {
  final GlobalKey<AnimatedDrawerLayoutState> drawerLayoutKey =
      GlobalKey<AnimatedDrawerLayoutState>();

  TagScreen({super.key});

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
                      onLogoImageTap: () {
                        drawerLayoutKey.currentState?.toggleLeftMenu();
                      },
                      onProfileTap: () {
                        drawerLayoutKey.currentState?.toggleRightMenu();
                      },
                    ),
                    Consumer<TagifyProvider>(
                      builder: (context, provider, child) {
                        return Container(
                          color: whiteBackgroundColor,
                          height: tagScreenGridSelectBarHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  provider.selectedGrid == 2
                                      ? CupertinoIcons.square_grid_2x2_fill
                                      : CupertinoIcons.square_grid_2x2,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  provider.tagScreenSelectedGrid = 2;
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  provider.selectedGrid == 3
                                      ? CupertinoIcons.square_grid_3x2_fill
                                      : CupertinoIcons.square_grid_3x2,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  provider.tagScreenSelectedGrid = 3;
                                },
                              ),
                              const SizedBox(width: 20.0),
                            ],
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                        child: Consumer<TagifyProvider>(
                          builder: (context, provider, child) {
                            return TagGridView(
                              selectedGrid: provider.selectedGrid,
                            );
                          },
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

class TagGridView extends StatelessWidget {
  final int selectedGrid;

  const TagGridView({
    super.key,
    required this.selectedGrid,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: true);

    return GridView.builder(
      padding: EdgeInsets.only(bottom: 150.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: selectedGrid,
        crossAxisSpacing: 7.0,
        mainAxisSpacing: 7.0,
        childAspectRatio: 1.5,
      ),
      itemCount: provider.tags.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.all(6.0),
            child: TagBoxInstance(
              tag: null,
              onTap: () async {
                setTagBottomModal(
                  context,
                  (String newTag) async {
                    await provider.pvPostTag(newTag);
                  },
                );
              },
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(6.0),
          child: TagBoxInstance(
            tag: provider.tags[index - 1],
            onTap: () async {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  maintainState: true,
                  fullscreenDialog: false,
                  builder: (context) =>
                      TagDetailScreen(tag: provider.tags[index - 1]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
