import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class ArticleSearchBar extends StatelessWidget {
  const ArticleSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController articleController = TextEditingController();

    return Container(
      color: whiteBackgroundColor,
      height: exploreScreenSearchBarBoxHeight,
      child: Center(
        child: SizedBox(
          height: exploreScreenSearchBarHeight,
          width: MediaQuery.of(context).size.width * (0.95),
          child: TextField(
            controller: articleController,
            cursorColor: exploreScreenSearchBorderColor,
            autocorrect: false,
            autofocus: false,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(CupertinoIcons.clear_circled_solid),
                onPressed: () {
                  articleController.text = "";
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: exploreScreenSearchBorderColor,
                  width: 1.5,
                ),
              ),
              hintText: tr('explore_screen_search_hint_text'),
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
            ),
          ),
        ),
      ),
    );
  }
}
