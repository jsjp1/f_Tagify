import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/components/analyze/content_edit_widget.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  AnalyzeScreenState createState() => AnalyzeScreenState();
}

class AnalyzeScreenState extends State<AnalyzeScreen> {
  ApiResponse<Content> futureContent = ApiResponse.empty();
  final TextEditingController _controller = TextEditingController();
  bool invalidUrl = false;
  bool alreadyExistsError = false;

  Future<void> _contentAnalyze(
      String url, String lang, String contentType) async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    final result = await analyzeContent(provider.loginResponse!["id"], url,
        lang, contentType, provider.loginResponse!["access_token"]);
    setState(() {
      futureContent = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double pageWidth = MediaQuery.of(context).size.width * (0.9);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: pageWidth,
                child: Column(
                  children: [
                    // appBar 부분
                    SizedBox(
                      height: safeAreaHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(CupertinoIcons.back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    // 링크 검색 텍스트 부분
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 10.0),
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
                    // 링크 검색 텍스트 필드 부분
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.08),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              cursorColor: mainColor,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide(width: 2.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: mainColor, width: 2.0),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                suffixIcon: IconButton(
                                  icon:
                                      Icon(CupertinoIcons.clear_circled_solid),
                                  onPressed: () {
                                    _controller.text = "";
                                  },
                                ),
                              ),
                            ),
                          ),
                          // 링크 검색 텍스트 필드 옆 검색 아이콘 버튼
                          IconButton(
                            icon: Icon(
                              CupertinoIcons.search,
                              size: 30.0,
                            ),
                            onPressed: () async {
                              String url = _controller.text;
                              if (!isValidUrl(url)) {
                                setState(() {
                                  invalidUrl = true;
                                });
                                return;
                              }
                              setState(() {
                                invalidUrl = false;
                              });

                              await _contentAnalyze(
                                  url,
                                  "ko",
                                  isVideo(url)
                                      ? "video"
                                      : "post"); // TODO: lang ko x

                              if (futureContent.statusCode == 500) {
                                setState(() {
                                  alreadyExistsError = true;
                                });
                                return;
                              }
                              setState(() {
                                alreadyExistsError = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    invalidUrl
                        ? SizedBox(
                            height: 15.0,
                            child: Padding(
                              padding: EdgeInsets.only(left: 13.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: GlobalText(
                                  localizeText: "analyze_screen_invalid_url",
                                  textSize: 13.5,
                                  textColor: mainColor,
                                  localization: true,
                                  isBold: true,
                                ),
                              ),
                            ),
                          )
                        : alreadyExistsError
                            ? SizedBox(
                                height: 15.0,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 13.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: GlobalText(
                                      localizeText:
                                          "analyze_screen_already_exists",
                                      textSize: 13.5,
                                      textColor: mainColor,
                                      localization: true,
                                      isBold: true,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(height: 15.0),
                  ],
                ),
              ),
            ),

            // 컨텐츠 정보 나열, 스크롤 가능 부분
            if (futureContent.data != null)
              Positioned(
                top: MediaQuery.of(context).size.height * (0.08) + 140.0,
                left: 0,
                right: 0,
                bottom: 0,
                child: ContentEditWidget(
                  content: futureContent.data!,
                  isEdit: false,
                  widgetWidth: pageWidth,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool isVideo(String url) {
    // TODO: 로직 개선
    return url.contains("youtu");
  }

  bool isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAbsolutePath;
  }
}
