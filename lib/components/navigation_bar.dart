import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagify/global.dart';

class TagifyNavigationBar extends StatelessWidget {
  final dynamic loginResponse;

  const TagifyNavigationBar({super.key, required this.loginResponse});

  @override
  Widget build(BuildContext context) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    debugPrint("$currentRoute");

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 80.0,
          color: whiteBackgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: 35.0,
                icon: Icon(CupertinoIcons.house),
                onPressed: () {},
              ),
              SizedBox(width: 60),
              IconButton(
                iconSize: 35.0,
                icon: Icon(CupertinoIcons.folder),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 40,
          left: MediaQuery.of(context).size.width / 2 - 35,
          child: Container(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              onPressed: () {
                debugPrint("Floating Button Clicked!");
              },
              shape: StadiumBorder(),
              backgroundColor: mainColor,
              child: Text("🏷️", style: TextStyle(fontSize: 40)),
            ),
          ),
        ),
      ],
    );
  }
}
