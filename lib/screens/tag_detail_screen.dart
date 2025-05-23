import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/content_widget.dart';
import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/tag/tag_color_picker.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/utils/banner_ad_widget.dart';

class TagDetailScreen extends StatefulWidget {
  final Tag tag;

  const TagDetailScreen({super.key, required this.tag});

  @override
  TagDetailScreenState createState() => TagDetailScreenState();
}

class TagDetailScreenState extends State<TagDetailScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TagifyProvider>(context, listen: true);

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          color: isDarkMode ? darkNoticeWidgetColor : noticeWidgetColor,
          child: Stack(
            children: [
              Column(
                children: [
                  TagifyAppBar(
                    addText: "/ ${widget.tag.tagName}",
                    appIconColor: widget.tag.color,
                    onLogoImageTap: () async {
                      await themeColorChange(
                        context,
                        provider,
                        widget.tag.id,
                        widget.tag.tagName,
                      );
                    },
                  ),
                  Expanded(
                    child: ContentWidget(
                      tagSelectedId: widget.tag.id,
                      tagSelectedName: widget.tag.tagName,
                    ),
                  ),
                ],
              ),
              provider.loginResponse!["is_premium"] == false
                  ? Positioned(
                      key: UniqueKey(),
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Center(
                        child: const BannerAdWidget(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
