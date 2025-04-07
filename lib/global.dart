import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const Color mainColor = Color.fromARGB(255, 205, 20, 31);
// const Color mainColor = Color.fromARGB(255, 234, 51, 61);
const Color whiteBackgroundColor = Colors.white;
const Color blackBackgroundColor = Colors.black;
const Color lightBlackBackgroundColor = Color.fromARGB(255, 36, 36, 36);
const Color noticeWidgetColor = Color.fromARGB(255, 245, 245, 245);
const Color moreNoticeWidgetColor = Color.fromARGB(255, 229, 229, 229);
const Color darkNoticeWidgetColor = Color.fromARGB(255, 47, 47, 47);
const Color timeContainerColor = Color.fromARGB(200, 225, 225, 225);
const Color tagColor = Color.fromARGB(255, 50, 50, 50);
const Color containerTitleColor = Color.fromARGB(255, 78, 78, 78);
const Color profileButtonContainerColor = Color.fromARGB(255, 200, 200, 200);
const Color navigationSearchBarColor = Colors.white70;
const Color contentInstanceTagTextColor = Colors.indigo;
const Color darkContentInstanceTagTextColor =
    Color.fromARGB(255, 143, 159, 252);
const Color contentInstanceTagBorderColor = Color.fromARGB(255, 209, 209, 209);
const Color analyzeScreenTextColor = Color.fromARGB(255, 133, 133, 133);
const Color contentInstanceBoxShadowColor = Color.fromARGB(255, 225, 225, 225);
const Color darkContentInstanceBoxShadowColor =
    Color.fromARGB(255, 100, 100, 100);
const Color contentInstanceNoThumbnailColor =
    Color.fromARGB(200, 255, 255, 255);
const Color tagBoxInstanceColor = Color.fromARGB(149, 255, 255, 255);
const Color defaultTagFolderColor = Color.fromARGB(155, 191, 191, 191);
const Color snackBarColor = Color.fromARGB(255, 111, 111, 111);
const Color contentInstanceDescriptionColor = Color.fromARGB(255, 99, 99, 99);
const Color exploreScreenSearchBorderColor = Color.fromARGB(255, 87, 87, 87);

// widget height
const double appBarHeight = 45.0;
const double navigationBarHeight = 83.0;
const double logoImageHeight = 35.0;
const double safeAreaHeight = 60.0;
const double articleInstanceHeight = 110.0;
const double profileImageHeight = 35.0;
const double profileImageHeightInArticle = 20.0;
const double profileImageHeightInComment = 25.0;
const double profileImageHeightInArticleWidget = 15.0;
const double profileImageHeightInArticleDetail = 35.0;
const double uploadDialogHeight = 328.0;
const double navigationBarIconButtonHeight = 60.0;
const double exploreScreenSearchBarBoxHeight = 55.0;
const double exploreScreenSearchBarHeight = 40.0;
const double tagScreenGridSelectBarHeight = 40.0;
const double articleDetailScreenThumbnailsHeight = 200.0;
const double articleDetailScreenContentHeight = 150.0;
const double settingsScreenProfileImageHeight = 75.0;
const double articleInstanceDownloadButtonSize = 24.0;
const double articleInstanceThumbnailHeight = 83.0;

// global variable
const int articlesLimit = 30;

// global font size
const double contentInstanceTitleFontSize = 15.0;
const double contentInstanceDescriptionFontSize = 10.0;

class GlobalText extends StatelessWidget {
  final String localizeText;
  final double textSize;
  final bool localization;
  final bool? isBold;
  final Color? textColor;
  final TextOverflow? overflow;
  final int? maxLines;

  GlobalText({
    super.key,
    required this.localizeText,
    required this.textSize,
    this.isBold,
    this.textColor,
    this.overflow,
    this.localization = true,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return localization
        ? Text(
            localizeText,
            maxLines: maxLines,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontFamily: "YoutubeFont",
              fontWeight:
                  (isBold ?? false) ? FontWeight.bold : FontWeight.normal,
              overflow: overflow,
            ),
          ).tr()
        : Text(
            localizeText,
            maxLines: maxLines,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontFamily: "YoutubeFont",
              fontWeight:
                  (isBold ?? false) ? FontWeight.bold : FontWeight.normal,
              overflow: overflow,
            ),
          );
  }
}

class CustomPageRouteBuilder<T> extends PageRoute<T> {
  final RoutePageBuilder pageBuilder;
  final PageTransitionsBuilder matchingBuilder =
      const CupertinoPageTransitionsBuilder();

  CustomPageRouteBuilder({required this.pageBuilder});

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return pageBuilder(context, animation, secondaryAnimation);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return matchingBuilder.buildTransitions<T>(
        this, context, animation, secondaryAnimation, child);
  }
}
