import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/api/content.dart';
import 'package:tagify/components/contents/content_widget.dart';
import 'package:tagify/global.dart';

class TagifyNavigationBar extends StatelessWidget {
  final Map<String, dynamic> loginResponse;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ContentWidgetState> contentWidgetKey;

  TagifyNavigationBar(
      {super.key, required this.loginResponse, required this.contentWidgetKey});

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
                  onPressed: () {
                    // TODO
                  },
                ),
              ),
              SizedBox(width: 60),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: IconButton(
                  iconSize: 30.0,
                  icon: Icon(CupertinoIcons.folder_fill),
                  onPressed: () {
                    // TODO
                  },
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

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Colors.red,
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(CupertinoIcons.doc_text_search),
                        style: ButtonStyle(
                          iconColor: WidgetStateProperty.all(mainColor),
                        ),
                        onPressed: () async {
                          dynamic _ = await analyzeVideo(
                              loginResponse["oauth_id"],
                              _searchController.text,
                              "ko");
                          contentWidgetKey.currentState
                              ?.refreshContents(); // video analyze시 contents 다시 불러오기
                          Navigator.of(context).pop();
                        },
                      ),
                      hintText: tr("navigation_bar_input_link_hint"),
                      filled: true,
                      fillColor: navigationSearchBarColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide:
                            const BorderSide(color: mainColor, width: 4.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide:
                            const BorderSide(color: mainColor, width: 4.0),
                      ),
                    ),
                    onSubmitted: (String value) async {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
