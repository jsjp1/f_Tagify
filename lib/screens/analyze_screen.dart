import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/components/analyze/content_edit_widget.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/utils/util.dart';

class AnalyzeScreen extends StatefulWidget {
  final String? initialUrl;
  const AnalyzeScreen({super.key, this.initialUrl});

  @override
  AnalyzeScreenState createState() => AnalyzeScreenState();
}

class AnalyzeScreenState extends State<AnalyzeScreen> {
  ApiResponse<Content> futureContent = ApiResponse.empty();
  late TextEditingController _controller;
  late bool invalidUrl;
  late bool alreadyExistsError;

  final analyzeMode = ["analyze_screen_link", "analyze_screen_memo"];
  int currentModeIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl ?? "");

    setState(() {
      invalidUrl = false;
      alreadyExistsError = false;
    });
  }

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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double pageWidth = MediaQuery.of(context).size.width * (0.9);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: true,
        bottom: false,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
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
                  // TODO
                  SizedBox(
                    height: 30.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: analyzeMode.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                currentModeIndex = index;

                                // 기존에 남아있는 에러 문구 제거
                                invalidUrl = false;
                                alreadyExistsError = false;
                              });
                            },
                            child: Container(
                              width: 50.0,
                              height: 30.0,
                              decoration: BoxDecoration(
                                color: index == currentModeIndex
                                    ? mainColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Center(
                                  child: GlobalText(
                                    localizeText: analyzeMode[index],
                                    textColor: index == currentModeIndex
                                        ? (isDarkMode
                                            ? lightBlackBackgroundColor
                                            : whiteBackgroundColor)
                                        : (isDarkMode
                                            ? whiteBackgroundColor
                                            : lightBlackBackgroundColor),
                                    isBold: true,
                                    textSize: 13.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  // 링크 검색 텍스트 부분
                  currentModeIndex == 0
                      ? Padding(
                          padding: EdgeInsets.only(left: 10.0, top: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GlobalText(
                              localizeText: "analyze_screen_enter_link",
                              textSize: 27.0,
                              localization: true,
                              isBold: true,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  // 링크 검색 텍스트 필드 부분
                  currentModeIndex == 0
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * (0.08),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  autocorrect: false,
                                  autofocus: true,
                                  cursorColor: mainColor,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: BorderSide(width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: mainColor, width: 1.3),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    suffixIcon: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 35.0,
                                          height: 35.0,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                                Icons.content_paste_sharp,
                                                size: 22.0),
                                            onPressed: () async {
                                              final clipboardData =
                                                  await Clipboard.getData(
                                                      'text/plain');
                                              if (clipboardData != null) {
                                                _controller.text =
                                                    clipboardData.text!;
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 35.0,
                                          height: 35.0,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                                CupertinoIcons
                                                    .clear_circled_solid,
                                                size: 22.0),
                                            onPressed: () {
                                              _controller.clear();
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10.0),
                                      ],
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

                                  if (futureContent.statusCode == 400) {
                                    // 이미 링크가 존재하는 경우
                                    setState(() {
                                      alreadyExistsError = true;
                                    });
                                    return;
                                  } else if (futureContent.statusCode == 422) {
                                    // 잘못된 url 형식
                                    // e.g. htp://~~~
                                    // 문자열1 https://www.example.com 문자열2 와 같은 경우는 정상 동작

                                    // 이미 위에서도 isValidUrl로 검증했지만, 한번더
                                    invalidUrl = true;
                                  }

                                  setState(() {
                                    alreadyExistsError = false;
                                    invalidUrl = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
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

                  // 컨텐츠 정보 나열, 스크롤 가능 부분
                  currentModeIndex == 0 // link 모드
                      ? futureContent.data != null
                          ? Expanded(
                              child: ContentEditWidget(
                                isLink: true,
                                content: futureContent.data!,
                                isEdit: false,
                                widgetWidth: pageWidth,
                              ),
                            )
                          : SizedBox.shrink()
                      : Expanded(
                          // memo 모드
                          child: ContentEditWidget(
                            isLink: false,
                            content: Content.empty(),
                            isEdit: false,
                            widgetWidth: pageWidth,
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
