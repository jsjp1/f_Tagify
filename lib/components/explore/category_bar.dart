import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class CategoryBar extends StatefulWidget {
  final List<String> categoryList;

  const CategoryBar({super.key, required this.categoryList});

  @override
  CategoryBarState createState() => CategoryBarState();
}

class CategoryBarState extends State<CategoryBar> {
  int currentCategory = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: false);
    currentCategory = provider.currentCategory;

    return SizedBox(
      height: 40.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categoryList.length + 1,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(width: 10.0);
          } else {
            return GestureDetector(
              onTap: () {
                setState(() {
                  currentCategory = index - 1;
                });
                provider.currentCategory = index - 1;
              },
              child: CategoryContainer(
                categoryName: widget.categoryList[index - 1],
                isSelected: currentCategory == index - 1,
              ),
            );
          }
        },
      ),
    );
  }
}

class CategoryContainer extends StatelessWidget {
  final String categoryName;
  bool isSelected;

  CategoryContainer({
    super.key,
    required this.categoryName,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicWidth(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: isSelected
                ? (isDarkMode ? noticeWidgetColor : darkNoticeWidgetColor)
                : (isDarkMode ? darkNoticeWidgetColor : noticeWidgetColor),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
            child: Center(
              child: GlobalText(
                localizeText: categoryName, // TODO: localization
                textSize: 13.0,
                textColor: isSelected
                    ? (isDarkMode ? darkNoticeWidgetColor : noticeWidgetColor)
                    : (isDarkMode ? noticeWidgetColor : darkNoticeWidgetColor),
                isBold: true,
                localization: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
