import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/common/tag_container.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/tagged_article_screen.dart';

class TagsViewer extends StatelessWidget {
  final String categoryName;
  final Future<List<Map<String, dynamic>>> Function(int, String) futureFunction;

  const TagsViewer(
      {super.key, required this.categoryName, required this.futureFunction});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return categoryName == "all" // all이면 태그 표시 x
        ? SizedBox.shrink()
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.175,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 20.0),
                  child: GlobalText(
                    localizeText: "Paying Attention", // TODO: localization
                    textSize: 13.0,
                    isBold: true,
                  ),
                ),
                Expanded(
                  child: Consumer<TagifyProvider>(
                    builder: (context, provider, child) {
                      return FutureBuilder(
                        future: futureFunction(24, categoryName),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: GlobalText(
                                localizeText:
                                    "Waiting Please 🥺...", // TODO: localization
                                textSize: 13.0,
                                isBold: true,
                                localization: true,
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final tags = snapshot.data!;

                          // TODO: iPad에서 확인했을 때 UI 최적화 안돼있음
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                3,
                                (colIndex) => Row(
                                  children: List.generate(
                                    8,
                                    (rowIndex) {
                                      int tagIndex = colIndex * 8 + rowIndex;
                                      if (tagIndex >= tags.length) {
                                        return const SizedBox.shrink();
                                      }

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 10.0,
                                          left: tagIndex % 8 == 0 ? 15.0 : 0.0,
                                        ),
                                        child: TagContainer(
                                          tagName: tags[tagIndex]["tagname"],
                                          textSize: 13.0,
                                          tagColor: isDarkMode
                                              ? whiteBackgroundColor
                                              : darkNoticeWidgetColor,
                                          onTap: () {
                                            // TODO: TagDetailScreen으로 넘어가지 말고, 해당 받아온 컨텐츠들을,
                                            // TODO: 아래 ContentsViewer에서 표시하도록.
                                            // 일단 아래와 같이 -> 추후 바꾸기
                                            Navigator.push(
                                              context,
                                              CustomPageRouteBuilder(
                                                pageBuilder: (context,
                                                    animation,
                                                    secondaryAnimation) {
                                                  return TaggedArticleScreen(
                                                    tagId: tags[tagIndex]["id"],
                                                    tagName: tags[tagIndex]
                                                        ["tagname"],
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
