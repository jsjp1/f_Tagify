import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController searchTextController = TextEditingController();

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double widgetWidth = MediaQuery.of(context).size.width * (0.85);
    final double widgetHeight = MediaQuery.of(context).size.height * (0.05);

    return Column(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * (0.07),
          child: Align(
            alignment: Alignment.topCenter,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: widgetWidth,
                height: widgetHeight,
                child: Center(
                  child: TextField(
                    autocorrect: false,
                    cursorHeight: 15.0,
                    cursorColor: Colors.grey,
                    controller: searchTextController,
                    decoration: InputDecoration(
                      hintText: tr("search_bar_hint_text"),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(10.0, 8.0, 0.0, 0.0),
                      suffixIcon: IconButton(
                        icon: Icon(
                          CupertinoIcons.clear_circled_solid,
                          size: 20.0,
                        ),
                        onPressed: () {
                          searchTextController.text = "";
                        },
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? darkNoticeWidgetColor
                          : noticeWidgetColor,
                    ),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 1,
          thickness: 0.2,
        ),
      ],
    );
  }
}
