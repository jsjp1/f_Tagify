import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagify/api/article.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/api/tag.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';

class TagifyProvider extends ChangeNotifier {
  bool hasMoreArticles = true;
  String _currentTag = "all";
  String _currentPage = "home";
  List<Tag> _tags = [];
  Map<int, String> _idTagNameMap = {};
  Set<int> _bookmarkedSet = {};
  final Map<String, List<Content>> _tagContentsMap = {};
  List<Article> _articles = [];

  Map<String, dynamic>? _loginResponse;
  int _tagScreenSelectedGrid = 2;
  int _articlesOffset = 0;

  final int _articleLimit = 30;
  int _articleOffset = 0;

  String get currentTag => _currentTag;
  String get currentPage => _currentPage;
  Map<String, List<Content>> get tagContentsMap => _tagContentsMap;
  List<Article> get articles => _articles;
  List<Tag> get tags => _tags;
  Set<int> get bookmarkedSet => _bookmarkedSet;
  Map<String, dynamic>? get loginResponse => _loginResponse;
  int get selectedGrid => _tagScreenSelectedGrid;
  int get articlesOffset => _articlesOffset;

  set currentPage(String newPage) {
    _currentPage = newPage;
    notifyListeners();
  }

  void setCurrentPageNotNotify(String newPage) {
    _currentPage = newPage;
  }

  set currentTag(String newTag) {
    _currentTag = newTag;
    notifyListeners();
  }

  set tags(List<Tag> newTags) {
    _tags = newTags;
    notifyListeners();
  }

  set articles(List<Article> newArticles) {
    _articles = newArticles;
    notifyListeners();
  }

  void setArticles(List<Article> newArticles) {
    _articles = newArticles;
    notifyListeners();
  }

  void addArticles(List<Article> moreArticles) {
    _articles.addAll(moreArticles);
    notifyListeners();
  }

  set tagScreenSelectedGrid(int grids) {
    _tagScreenSelectedGrid = grids;
    notifyListeners();
  }

  void setTagContents(String tag, List<Content> contents) {
    tagContentsMap[tag] = contents;
    notifyListeners();
  }

  List<Content> getTagContents(String tag) {
    return tagContentsMap[tag]!;
  }

  void setTagNotNotify(String newTag) {
    _currentTag = newTag;
  }

  void setSelectedGrid(int newGrid) {
    _tagScreenSelectedGrid = newGrid;
    notifyListeners();
  }

  void updateArticlesOffset() {
    _articlesOffset += articlesLimit;
  }

  void changeUserInfo(String key, dynamic value) {
    if (_loginResponse == null) return;

    _loginResponse![key] = value;
    notifyListeners();
  }

  Future<void> pvFetchUserAllContents() async {
    if (_loginResponse == null) return;

    ApiResponse<List<Content>> c = await fetchUserContents(
        _loginResponse!["id"], _loginResponse!["access_token"]);

    if (c.success) {
      _tagContentsMap["all"] = c.data!;
      notifyListeners();
    }
  }

  Future<void> pvSaveContent(Content content) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<Map<String, dynamic>> c =
        await saveContent(content, _loginResponse!["id"], accessToken!);

    if (c.success) {
      Map<String, dynamic> responseMap = c.data!;

      int newContentId = responseMap["id"];
      List<Tag> tags = responseMap["tags"];

      if (content.bookmark) {
        _bookmarkedSet.add(newContentId);
        _tagContentsMap["bookmark"]!.add(content);
      }
      pvFetchUserAllContents();

      for (var t in tags) {
        if (_tags.contains(t) == false) {
          _tags.insert(0, t);
        }

        _idTagNameMap[t.id] = t.tagName;

        if (_tagContentsMap[t.tagName] == null) {
          _tagContentsMap[t.tagName] = [];
        }
        _tagContentsMap[t.tagName]!.add(content);
      }

      notifyListeners();
    }
  }

  Future<void> pvFetchUserBookmarkedContents() async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<List<Content>> c =
        await fetchBookmarkContents(_loginResponse!["id"], accessToken!);

    if (c.success) {
      _tagContentsMap["bookmark"] = c.data!;
      for (var d in c.data!) {
        if (d.bookmark == true) {
          _bookmarkedSet.add(d.id);
        }
      }
      notifyListeners();
    }
  }

  Future<void> pvFetchUserTagContents(int tagId, String tagName) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<List<Content>> c =
        await fetchUserTagAllContents(tagId, accessToken!);

    if (c.success) {
      if (_idTagNameMap[tagId] == null) {
        _idTagNameMap[tagId] = tagName;
      }
      if (_tagContentsMap[tagName] == null) {
        _tagContentsMap[tagName] = [];
      }
      _tagContentsMap[tagName] = c.data!;
      notifyListeners();
    }
  }

  Future<void> pvDeleteUserContent(int contentId) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> c = await deleteContent(contentId, accessToken!);

    if (c.success) {
      _tagContentsMap.forEach((tag, contents) {
        _tagContentsMap[tag] =
            contents.where((content) => content.id != contentId).toList();
      });

      pvFetchUserTags();
      notifyListeners();
    }
  }

  Future<void> pvToggleBookmark(int contentId) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> c = await toggleBookmark(contentId, accessToken!);

    if (c.success) {
      var bookmarkList = _tagContentsMap["bookmark"];

      if (bookmarkList != null) {
        if (bookmarkList.any((content) => content.id == contentId)) {
          _tagContentsMap["bookmark"] =
              bookmarkList.where((content) => content.id != contentId).toList();

          _bookmarkedSet.remove(contentId);
        } else {
          Content? targetContent;

          for (var contents in _tagContentsMap.values) {
            targetContent = contents.firstWhere(
              (content) => content.id == contentId,
              orElse: () => Content.empty(),
            );
            if (targetContent.id != -1) break;
          }

          if (targetContent != null && targetContent.id != -1) {
            _tagContentsMap["bookmark"] = [
              ...?_tagContentsMap["bookmark"],
              targetContent,
            ];
          }

          _bookmarkedSet.add(contentId);
        }
      }

      pvFetchUserBookmarkedContents();
      notifyListeners();
    }
  }

  Future<void> pvFetchUserTags() async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<List<Tag>> t =
        await fetchUserTags(_loginResponse!["id"], accessToken!);

    if (t.success) {
      _tags = t.data!;

      // tag id와 tagname 정보 매핑
      for (var tag in _tags) {
        _idTagNameMap[tag.id] = tag.tagName;
      }
      notifyListeners();
    }
  }

  Future<void> pvPostTag(String newTagName) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<Tag> t =
        await postTag(_loginResponse!["id"], newTagName, accessToken!);

    if (t.success) {
      // _nameTagMap[newTagName] = t.data!;
      _idTagNameMap[t.data!.id] = t.data!.tagName;
      _tags.insert(0, t.data!);
      notifyListeners();
    }
  }

  Future<bool> pvDeleteTag(String tagName) async {
    if (_loginResponse == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> t =
        await deleteTag(_loginResponse!["id"], tagName, accessToken!);

    if (t.success) {
      _idTagNameMap.remove(t.data!);
      pvFetchUserTags();
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<void> pvFetchArticlesLimited() async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<List<Article>> a =
        await fetchArticlesLimited(_articleLimit, _articleOffset, accessToken!);

    if (a.success) {
      _articles = a.data!;
      _articleOffset += _articleLimit;
      notifyListeners();
    }
  }

  Future<void> pvFetchRefreshedArticles() async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<List<Article>> a =
        await fetchArticlesLimited(_articleLimit, 0, accessToken!);

    if (a.success) {
      _articles = a.data!;
      _articleOffset += _articleLimit;
      notifyListeners();
    }
  }

  Future<void> pvPostArticle(
      String title, String body, String encodedContent) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> a = await postArticle(
        _loginResponse!["id"], title, body, encodedContent, accessToken!);

    if (a.success) {
      pvFetchRefreshedArticles();
      notifyListeners();
    }
  }

  Future<void> pvDeleteArticle(int articleId) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> a =
        await deleteArticle(_loginResponse!["id"], articleId, accessToken!);

    if (a.success) {
      pvFetchRefreshedArticles();
      notifyListeners();
    }
  }

  Future<void> pvDownloadArticle(String newTagName, int articleId) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> a = await downloadArticle(
        _loginResponse!["id"], newTagName, articleId, accessToken!);

    if (a.success) {
      pvFetchUserAllContents();
      pvFetchUserTags();
      notifyListeners();
    }
  }

  Future<void> setInitialSetting(Map<String, dynamic> loginResponse) async {
    _loginResponse = loginResponse;
  }
}
