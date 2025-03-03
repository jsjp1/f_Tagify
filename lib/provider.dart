import 'package:flutter/material.dart';

import 'package:tagify/api/article.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/api/tag.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';

// TODO: 일단 화면 전환 후 await / 현재는 await then 전환
class TagifyProvider extends ChangeNotifier {
  String _currentTag = "all";
  String _currentPage = "home";
  List<Content> _contents = [];
  List<Article> _articles = [];
  List<Tag> _tags = [];

  Map<String, List<Content>> _tagCachedContents = {};

  Map<String, dynamic>? _loginResponse;
  Map<String, int> _tagNameIdMap = {};
  int _tagScreenSelectedGrid = 2;
  int _articlesOffset = 0;

  String get currentTag => _currentTag;
  String get currentPage => _currentPage;
  List<Content> get contents => _contents;
  List<Article> get articles => _articles;
  List<Tag> get tags => _tags;
  Map<String, dynamic>? get loginResponse => _loginResponse;
  int get selectedGrid => _tagScreenSelectedGrid;
  int get articlesOffset => _articlesOffset;

  void setCurrentPage(String newPage) {
    _currentPage = newPage;
    notifyListeners();
  }

  void setSelectedGrid(int newGrid) {
    _tagScreenSelectedGrid = newGrid;
    notifyListeners();
  }

  void updateArticlesOffset() {
    _articlesOffset += articlesLimit;
  }

  Future<void> setUserInfo(Map<String, dynamic> loginResponse) async {
    _loginResponse = loginResponse;

    await fetchContents();
    await fetchTags();
    await fetchArticles();

    notifyListeners();
  }

  Future<void> setTag(String newTag) async {
    _currentTag = newTag;
  }

  void fetchCachedContents() async {
    _contents = _tagCachedContents[_currentTag]!;
  }

  Future<void> fetchContents() async {
    if (loginResponse!['id'] == null) return;

    ApiResponse<List<Content>> contentsResponse;
    switch (_currentTag) {
      case "all":
        contentsResponse = await fetchUserContents(loginResponse!["id"]);
        break;
      case "bookmark":
        contentsResponse = await fetchBookmarkContents(loginResponse!["id"]);
        break;
      default:
        contentsResponse =
            await fetchUserTagAllContents(_tagNameIdMap[_currentTag] ?? 0);
        break;
    }

    if (contentsResponse.success) {
      _contents = contentsResponse.data ?? [];
      _tagCachedContents[_currentTag] = contentsResponse.data ?? [];

      notifyListeners();
    }
  }

  Future<void> fetchTags() async {
    if (loginResponse!['id'] == null) return;
    final tagsResponse = await fetchUserTags(loginResponse!["id"]);

    if (tagsResponse.success) {
      _tags = tagsResponse.data ?? [];
      _tagNameIdMap.clear();
      for (var tag in _tags) {
        _tagNameIdMap[tag.tagName] = tag.id;
      }
    }
    notifyListeners();
  }

  Future<void> fetchArticles() async {
    if (loginResponse!['id'] == null) return;

    final articlesResponse = await fetchArticlesLimited(articlesLimit, 0);

    if (articlesResponse.success) {
      _articles = articlesResponse.data ?? [];
      notifyListeners();
    }
  }
}
