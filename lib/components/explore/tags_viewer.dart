import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/common/shimmer.dart';
import 'package:tagify/components/common/tag_container.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/tagged_article_screen.dart';

class TagsViewer extends StatefulWidget {
  final String categoryName;
  final Future<List<Map<String, dynamic>>> Function(int, String) futureFunction;

  const TagsViewer({
    required this.categoryName,
    required this.futureFunction,
    super.key,
  });

  @override
  State<TagsViewer> createState() => _TagsViewerState();
}

class _TagsViewerState extends State<TagsViewer> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = widget.futureFunction(24, widget.categoryName);
  }

  @override
  void didUpdateWidget(covariant TagsViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryName != widget.categoryName) {
      future = widget.futureFunction(24, widget.categoryName);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return widget.categoryName == "all" // all이면 태그 표시 x
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
                    localizeText: "explore_screen_tags", // TODO: localization
                    textSize: 13.0,
                    isBold: true,
                  ),
                ),
                Expanded(
                  child: Consumer<TagifyProvider>(
                    builder: (context, provider, child) {
                      return FutureBuilder(
                        future: future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                children: List.generate(3, (index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        right: index < 2 ? 10.0 : 0.0),
                                    child: TagShimmer(isDarkMode: isDarkMode),
                                  );
                                }),
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
                                              ? darkContentInstanceTagTextColor
                                              : contentInstanceTagTextColor,
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
