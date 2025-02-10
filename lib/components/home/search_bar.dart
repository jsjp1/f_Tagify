import 'package:flutter/material.dart';
import 'package:tagify/global.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    final double widgetWidth = MediaQuery.of(context).size.width * (0.85);
    final double widgetHeight = MediaQuery.of(context).size.height * (0.05);

    return Column(
      children: [
        Container(
          color: whiteBackgroundColor,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * (0.09),
          child: Align(
            alignment: Alignment.topCenter,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: noticeWidgetColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: widgetWidth,
                height: widgetHeight,
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
