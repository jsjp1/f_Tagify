import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  AnalyzeScreenState createState() => AnalyzeScreenState();
}

class AnalyzeScreenState extends State<AnalyzeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteBackgroundColor,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: whiteBackgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * (0.9),
            child: Column(
              children: [
                SizedBox(height: 10.0),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GlobalText(
                      localizeText: "analyze_screen_enter_link",
                      textSize: 30.0,
                      localization: true,
                      isBold: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.08),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.search,
                          size: 30.0,
                        ),
                        onPressed: () {},
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
