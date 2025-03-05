import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/navigation_bar_ab.dart';
import 'package:tagify/components/tag/tag_box_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/tag.dart';
import 'package:tagify/components/analyze/new_tag_modal.dart';
import 'package:tagify/screens/tag_detail_screen.dart';

class TagScreen extends StatelessWidget {
  const TagScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                children: [
                  TagifyAppBar(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          context.watch<TagifyProvider>().selectedGrid == 2
                              ? CupertinoIcons.square_grid_2x2_fill
                              : CupertinoIcons.square_grid_2x2,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context.read<TagifyProvider>().setSelectedGrid(2);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          context.watch<TagifyProvider>().selectedGrid == 3
                              ? CupertinoIcons.square_grid_3x2_fill
                              : CupertinoIcons.square_grid_3x2,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context.read<TagifyProvider>().setSelectedGrid(3);
                        },
                      ),
                      const SizedBox(width: 20.0),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                      child: Consumer<TagifyProvider>(
                        builder: (context, provider, child) {
                          return GridView.builder(
                            padding: EdgeInsets.only(bottom: 150.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: provider.selectedGrid,
                                    crossAxisSpacing: 7.0,
                                    mainAxisSpacing: 7.0,
                                    childAspectRatio: 1.5),
                            itemCount: provider.tags.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: TagBoxInstance(
                                    tag: null,
                                    onTap: () async {
                                      setTagBottomModal(context,
                                          (String newTag) async {
                                        final response = await postTag(
                                            provider.loginResponse!["id"],
                                            newTag);

                                        await provider.fetchTags();
                                      });
                                    },
                                  ),
                                );
                              }

                              return Padding(
                                padding: EdgeInsets.all(6.0),
                                child: TagBoxInstance(
                                  tag: provider.tags[index - 1],
                                  onTap: () async {
                                    provider.setTag(
                                        provider.tags[index - 1].tagName);
                                    await provider.fetchContents();

                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        maintainState: true,
                                        fullscreenDialog: false,
                                        builder: (context) => TagDetailScreen(
                                            tag: provider.tags[index - 1]),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
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
                child: TagifyNavigationBarAB(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
