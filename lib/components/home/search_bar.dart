import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TagifyProvider>(context, listen: false);
    searchTextController.addListener(() {
      if (searchTextController.text.isEmpty) {
        provider.currentTag = "all";
      }
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TagifyProvider>(context, listen: false);
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
                    controller: searchTextController,
                    autocorrect: false,
                    autofocus: false,
                    cursorHeight: 15.0,
                    cursorColor: Colors.grey,
                    onSubmitted: (String value) async {
                      ApiResponse<List<Content>> c = await searchContents(
                        provider.loginResponse!["id"],
                        value,
                        provider.loginResponse!["access_token"],
                      );

                      if (c.success) {
                        provider.currentTag = "search";
                        provider.tagContentsMap["search"] = c.data!;
                      }
                    },
                    onChanged: (String value) {
                      if (value == "") {
                        provider.currentTag = "all";
                      }
                    },
                    decoration: InputDecoration(
                      hintText: tr("search_bar_hint_text"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(10.0, 8.0, 0.0, 0.0),
                      suffixIcon: IconButton(
                        icon: Icon(
                          CupertinoIcons.clear_circled_solid,
                          size: 20.0,
                        ),
                        onPressed: () {
                          provider.currentTag = "all";
                          searchTextController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? darkNoticeWidgetColor
                          : noticeWidgetColor,
                    ),
                    style: TextStyle(
                      color: isDarkMode
                          ? whiteBackgroundColor
                          : blackBackgroundColor,
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
