import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/navigation_bar.dart';
import 'package:tagify/components/tag/tag_box_instance.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/tag.dart';
import 'package:tagify/components/analyze/new_tag_modal.dart';
import 'package:tagify/screens/tag_detail_screen.dart';

class TagScreen extends StatefulWidget {
  const TagScreen({super.key});

  @override
  TagScreenState createState() => TagScreenState();
}

class TagScreenState extends State<TagScreen> {
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Consumer<TagifyProvider>(
                        builder: (context, provider, child) {
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 15.0,
                                    mainAxisSpacing: 15.0,
                                    childAspectRatio: 1.5),
                            itemCount: provider.tags.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return TagBoxInstance(
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
                                );
                              }

                              return TagBoxInstance(
                                tag: provider.tags[index - 1],
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TagDetailScreen(
                                              tag: provider.tags[index - 1])));
                                },
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
                child: TagifyNavigationBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
