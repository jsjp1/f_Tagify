import 'package:flutter/material.dart';

import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/components/home/navigation_bar_ab.dart';
import 'package:tagify/global.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
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
                ],
              ),
              Positioned(
                bottom: navigationBarHeight + 20.0,
                right: 20.0,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(CircleBorder()),
                    padding: WidgetStateProperty.all(EdgeInsets.all(10.0)),
                    backgroundColor: WidgetStateProperty.all(mainColor),
                  ),
                  onPressed: () {
                    // TODO
                  },
                  child: Icon(
                    Icons.create,
                    size: 30.0,
                    color: whiteBackgroundColor,
                  ),
                ),
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
