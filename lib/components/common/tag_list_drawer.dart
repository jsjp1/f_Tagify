import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/common/animated_drawer_layout.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/tag_detail_screen.dart';

class TagListDrawer extends StatelessWidget {
  final GlobalKey<AnimatedDrawerLayoutState> drawerLayoutKey;

  const TagListDrawer({super.key, required this.drawerLayoutKey});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: true);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlobalText(
                localizeText: "tag_list_drawer_tag_list",
                textSize: 20.0,
                isBold: true,
                localization: true,
              ),
            ),
            const Divider(color: Colors.grey, height: 0.0, thickness: 0.5),
            Expanded(
              child: ListView.builder(
                itemCount: provider.tags.length,
                itemBuilder: (context, index) {
                  final tag = provider.tags[index];
                  return ListTile(
                    title: Row(
                      children: [
                        Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: tag.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: GlobalText(
                              localizeText: tag.tagName,
                              textSize: 15.0,
                              localization: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      // 먼저 drawer 닫기
                      drawerLayoutKey.currentState!.toggleLeftMenu();

                      Future.delayed(Duration(milliseconds: 300), () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TagDetailScreen(tag: tag),
                          ),
                        );
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
