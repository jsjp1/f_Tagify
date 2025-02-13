import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/api/content.dart';
import 'package:tagify/global.dart';

class TagifyNavigationBar extends StatelessWidget {
  final dynamic loginResponse;
  final TextEditingController _searchController = TextEditingController();

  TagifyNavigationBar({super.key, required this.loginResponse});

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "검색어 입력...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (String value) async {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    // TODO: analyze logic 추가
                    dynamic _ = await analyzeVideo(loginResponse["oauth_id"],
                        _searchController.text, "ko");
                    Navigator.of(context).pop();
                  },
                  child: Text("검색"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 90.0,
          color: whiteBackgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: IconButton(
                  iconSize: 30.0,
                  icon: Icon(CupertinoIcons.house_alt_fill),
                  onPressed: () {},
                ),
              ),
              SizedBox(width: 60),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: IconButton(
                  iconSize: 30.0,
                  icon: Icon(CupertinoIcons.folder_fill),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 35,
          left: MediaQuery.of(context).size.width / 2 - 35,
          child: Container(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              onPressed: () {
                _showSearchDialog(context);
              },
              shape: StadiumBorder(),
              backgroundColor: mainColor,
              child: Image.asset("assets/img/app_logo_white.png"),
            ),
          ),
        ),
      ],
    );
  }
}

class FloatingSearch extends StatefulWidget {
  @override
  _FloatingSearchState createState() => _FloatingSearchState();
}

class _FloatingSearchState extends State<FloatingSearch> {
  final TextEditingController _searchController = TextEditingController();

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "검색어 입력...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (String value) {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("검색"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 35,
      left: MediaQuery.of(context).size.width / 2 - 35,
      child: Container(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () => _showSearchDialog(context), // ✅ 클릭 시 다이얼로그 실행
          shape: StadiumBorder(),
          backgroundColor: Colors.blueAccent,
          child: Image.asset("assets/img/app_logo_white.png"),
        ),
      ),
    );
  }
}
