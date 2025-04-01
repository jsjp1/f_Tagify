import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagify/api/article.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/components/explore/app_bar.dart';

import 'package:tagify/components/home/navigation_bar_ab.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/components/common/animated_drawer_layout.dart';
import 'package:tagify/screens/tagged_article_screen.dart';
import 'package:tagify/screens/upload_article_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  final GlobalKey<AnimatedDrawerLayoutState> drawerLayoutKey =
      GlobalKey<AnimatedDrawerLayoutState>();

  late Future<List<Map<String, dynamic>>> _popularTagsFuture;
  late Future<List<Map<String, dynamic>>> _hotTagsFuture;
  late Future<List<Map<String, dynamic>>> _upVoteTagsFuture;
  late Future<List<Map<String, dynamic>>> _newestTagsFuture;
  late Future<List<Map<String, dynamic>>> _myTagsFuture;
  late Future<List<Map<String, dynamic>>> _randomTagsFuture;

  @override
  void initState() {
    super.initState();

    _popularTagsFuture = getCategoryTagList(5, "popular");
    _hotTagsFuture = getCategoryTagList(3, "hot");
    _upVoteTagsFuture = getCategoryTagList(5, "upvote");
    _newestTagsFuture = getCategoryTagList(5, "newest");
    _myTagsFuture = getOwnedTagList(-1); // 전부 가져온다는 의미의 -1
    _randomTagsFuture = getCategoryTagList(3, "random");
  }

  Future<List<Map<String, dynamic>>> getCategoryTagList(
      int count, String category) async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    // [{id: 0, tagname: "test", total_down_count: 7777}] 과 같은 형식
    // 혹은 total_down_count 대신 total_up_count (in "좋아요가 가장 많은")
    ApiResponse<List<Map<String, dynamic>>> tags = await fetchCategoryTags(
        count, category, provider.loginResponse!["access_token"]);

    if (tags.success) {
      return tags.data!.map((item) {
        String countKey = item.containsKey("total_down_count")
            ? "total_down_count"
            : "total_up_count";
        return {
          "id": item["id"],
          "tagname": item["tagname"],
          countKey: item[countKey],
        };
      }).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getOwnedTagList(int count) async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    ApiResponse<List<Map<String, dynamic>>> tags = await fetchOwnewdTags(count,
        provider.loginResponse!["id"], provider.loginResponse!["access_token"]);

    if (tags.success) {
      return tags.data!
          .map((item) => {
                "id": item["id"],
                "tagname": item["tagname"],
              })
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Container(
              color: isDarkMode ? darkNoticeWidgetColor : noticeWidgetColor,
            ),
            Column(
              children: [
                TagifyExploreAppBar(appBarName: "Explore"),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 800.0,
                            color: isDarkMode
                                ? lightBlackBackgroundColor
                                : whiteBackgroundColor,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // TODO: 나중에 리스트로 한번에 묶기

                                  GlobalText(
                                    localizeText:
                                        "explore_screen_total_ranking_tag",
                                    textSize: 24.0,
                                    isBold: true,
                                  ),
                                  SizedBox(height: 10.0),
                                  // popular 태그 future로 받아오며, 받아올때까지 skeleton ui 사용
                                  TagsSkeletonUI(
                                    tags: _popularTagsFuture,
                                    // borderColor: mainColor,
                                    // borderWidth: 2.0,
                                  ),
                                  SizedBox(height: 30.0),

                                  GlobalText(
                                    localizeText:
                                        "explore_screen_current_hot_tag",
                                    textSize: 23.0,
                                    isBold: true,
                                  ),
                                  SizedBox(height: 10.0),
                                  TagsSkeletonUI(tags: _hotTagsFuture),
                                  SizedBox(height: 30.0),

                                  GlobalText(
                                    localizeText: "explore_screen_upvote_tag",
                                    textSize: 23.0,
                                    isBold: true,
                                  ),
                                  SizedBox(height: 10.0),
                                  TagsSkeletonUI(tags: _upVoteTagsFuture),
                                  SizedBox(height: 30.0),

                                  GlobalText(
                                    localizeText: "explore_screen_newest_tag",
                                    textSize: 23.0,
                                    isBold: true,
                                  ),
                                  SizedBox(height: 10.0),
                                  TagsSkeletonUI(tags: _newestTagsFuture),
                                  SizedBox(height: 30.0),

                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CustomPageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              TaggedArticleScreen(
                                            tagId: -1,
                                            tagName:
                                                tr("explore_screen_see_all"),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color.fromARGB(
                                                255, 67, 160, 235),
                                            const Color.fromARGB(
                                                255, 78, 158, 81)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7.0, vertical: 3.0),
                                        child: GlobalText(
                                          localizeText:
                                              "explore_screen_see_all",
                                          textSize: 23.0,
                                          isBold: true,
                                          localization: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 60.0),

                                  // 이부분 간격 살짝 넓게
                                  GlobalText(
                                    localizeText: "explore_screen_my_tag",
                                    textSize: 20.0,
                                    isBold: true,
                                  ),
                                  SizedBox(height: 10.0),
                                  TagsSkeletonUI(tags: _myTagsFuture),
                                  SizedBox(height: 25.0),

                                  Row(
                                    children: [
                                      GlobalText(
                                        localizeText:
                                            "explore_screen_random_tag",
                                        textSize: 20.0,
                                        isBold: true,
                                      ),
                                      SizedBox(width: 10.0),
                                      GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            _randomTagsFuture =
                                                getCategoryTagList(3, "random");
                                          });
                                        },
                                        child: Icon(
                                          Icons.replay,
                                          size: 17.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  TagsSkeletonUI(tags: _randomTagsFuture),
                                  SizedBox(height: 35.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: TagifyNavigationBar(),
            ),
            Positioned(
              right: 20.0,
              bottom: navigationBarHeight + 20.0,
              child: Container(
                decoration: BoxDecoration(
                  color: mainColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.upload, color: whiteBackgroundColor),
                  iconSize: 35.0,
                  onPressed: () async {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            UploadArticleScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleTagContainer extends StatelessWidget {
  final int tagId;
  final String tagName;
  final int? totalDownCount;

  final double? borderWidth;
  final Color? borderColor;

  const ArticleTagContainer({
    super.key,
    required this.tagId,
    required this.tagName,
    this.borderColor,
    this.borderWidth,
    this.totalDownCount,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CustomPageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                TaggedArticleScreen(
              tagId: tagId,
              tagName: tagName,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              width: borderWidth ?? 0.5,
              color: borderColor ??
                  (isDarkMode ? whiteBackgroundColor : Colors.black26),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.0),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  child: GlobalText(
                    localizeText: tagName,
                    textColor:
                        isDarkMode ? Colors.grey[300] : blackBackgroundColor,
                    isBold: true,
                    textSize: 13.0,
                    localization: false,
                  ),
                ),
              ),
              // TODO -> 태그 컨테이너 더 꾸미기
              // totalDownCount == null
              //     ? SizedBox.shrink()
              //     : Text("$totalDownCount"),
            ],
          ),
        ),
      ),
    );
  }
}

class TagsSkeletonUI extends StatelessWidget {
  late Future<List<Map<String, dynamic>>> tags;

  final double? borderWidth;
  final Color? borderColor;

  TagsSkeletonUI(
      {super.key, required this.tags, this.borderColor, this.borderWidth});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: tags,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                3,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  width: 60.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: isDarkMode
                        ? const Color.fromARGB(255, 80, 80, 80)
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return SizedBox.shrink();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        }

        final tags = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tags
                .map(
                  (tag) => ArticleTagContainer(
                    tagId: tag["id"],
                    tagName: tag["tagname"],
                    totalDownCount: tag["total_down_count"],
                    borderColor: borderColor,
                    borderWidth: borderWidth,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
