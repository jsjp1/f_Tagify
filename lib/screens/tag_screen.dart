import 'package:flutter/material.dart';

import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/navigation_bar.dart';
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
    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                TagifyAppBar(
                    profileImage: widget.loginResponse["profile_image"] ?? ""),
                Expanded(
                  child: Container(
                    color: noticeWidgetColor,
                  ),
                ),
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
    );
  }
}
