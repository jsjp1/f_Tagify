import 'package:flutter/material.dart';

import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/navigation_bar.dart';
import 'package:tagify/components/tag/tag_box_instance.dart';
import 'package:tagify/global.dart';

class TagScreen extends StatefulWidget {
  final Map<String, dynamic> loginResponse;
  const TagScreen({super.key, required this.loginResponse});

  @override
  TagScreenState createState() => TagScreenState();
}

class TagScreenState extends State<TagScreen> {
  @override
  Widget build(BuildContext context) {
    List<String> tags = [
      "Tag1",
      "Tag2",
      "Tag3",
      "Tag4",
      "Tag5",
    ]; // 예제 태그 리스트

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
                  TagifyAppBar(
                      profileImage:
                          widget.loginResponse["profile_image"] ?? ""),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15.0,
                              mainAxisSpacing: 15.0,
                              childAspectRatio: 1.5),
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        return TagBoxInstance(tagName: tags[index]);
                      },
                    ),
                  )),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: TagifyNavigationBar(
                  loginResponse: widget.loginResponse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
