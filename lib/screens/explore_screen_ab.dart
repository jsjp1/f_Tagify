import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagify/api/article.dart';
import 'package:tagify/api/common.dart';

import 'package:tagify/components/explore/app_bar.dart';
import 'package:tagify/components/explore/category_bar.dart';
import 'package:tagify/components/explore/contents_viewer.dart';
import 'package:tagify/components/explore/tags_viewer.dart';
import 'package:tagify/components/home/navigation_bar.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/upload_article_screen.dart';

class ExploreScreenAb extends StatefulWidget {
  const ExploreScreenAb({super.key});

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreenAb> {
  final List<String> categoryList = [
    "explore_screen_see_all",
    "explore_screen_total_ranking",
    "explore_screen_current_hot",
    "explore_screen_upvote",
    "explore_screen_newest",
    "explore_screen_my_tag",
    "explore_screen_random",
  ];

  final List<String> indexCategoryList = [
    "all",
    "popular",
    "hot",
    "upvote",
    "newest",
    "owned",
    "random",
  ];

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

  Future<List<Map<String, dynamic>>> getOwnedTagList(
      int count, String _) async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    ApiResponse<List<Map<String, dynamic>>> tags = await fetchOwnedTags(count,
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
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                TagifyExploreAppBar(appBarName: "Explore"),
                CategoryBar(categoryList: categoryList),

                // 현재 category에 따른 tags와 contents 결정
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Consumer<TagifyProvider>(
                          builder: (context, provider, child) {
                            return TagsViewer(
                              categoryName:
                                  indexCategoryList[provider.currentCategory],
                              futureFunction: provider.currentCategory == 5
                                  ? // my tags를 갖고오는 index라면
                                  getOwnedTagList
                                  : getCategoryTagList,
                            );
                          },
                        ),
                        // TODO: default ContentsViewer에서는 api로 받아온거,
                        // TODO: 만약 TagsViewer에서 선택되면 그 Contents로 provider 덮어쓰기
                        Consumer<TagifyProvider>(
                          builder: (context, provider, child) {
                            return ContentsViewer(
                              categoryName:
                                  indexCategoryList[provider.currentCategory],
                            );
                          },
                        ),
                      ],
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
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) {
                          return UploadArticleScreen();
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
