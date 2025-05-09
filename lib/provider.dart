import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_handler/share_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagify/api/article.dart';
import 'package:tagify/api/comment.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/api/tag.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';

class TagifyProvider extends ChangeNotifier {
  String _version = "";
  String _currentTag = "all";
  String _currentPage = "home";
  final List<String> _currentCategoryList = [
    "all",
    "popular",
    "hot",
    "upvote",
    "newest",
    "owned",
    "random",
  ];
  int _currentCategory = 0; // 0, 1, 2, 3, 4, 5, 6
  List<Tag> _tags = [];
  Map<int, String> _idTagNameMap = {};
  Set<int> _bookmarkedSet = {};
  List<Content> _searchResultContents = [];
  final Map<String, List<Content>> _tagContentsMap = {};
  final Map<String, List<Article>> _categoryArticlesMap = {};
  final Map<String, int> _categoryOffsetMap = {};
  final Map<String, bool> _hasMoreByCategory = {};
  List<String> _messageList = [];

  Map<String, dynamic>? _loginResponse;
  int _tagScreenSelectedGrid = 2;
  int _articlesOffset = 0;

  final int _articleLimit = 20;

  String get version => _version;
  String get currentTag => _currentTag;
  String get currentPage => _currentPage;
  int get currentCategory => _currentCategory;
  Map<String, List<Content>> get tagContentsMap => _tagContentsMap;
  Map<String, List<Article>> get categoryArticlesMap => _categoryArticlesMap;
  Map<String, int> get categoryOffsetMap => _categoryOffsetMap;
  Map<String, bool> get hasMoreByCategory => _hasMoreByCategory;
  List<Tag> get tags => _tags;
  Set<int> get bookmarkedSet => _bookmarkedSet;
  List<Content> get searchResultContents => _searchResultContents;
  Map<String, dynamic>? get loginResponse => _loginResponse;
  int get selectedGrid => _tagScreenSelectedGrid;
  int get articlesOffset => _articlesOffset;
  List<String> get messageList => _messageList;

  set version(String version) {
    _version = version;
    notifyListeners();
  }

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

  set currentCategory(int currentCategory) {
    _currentCategory = currentCategory;
    notifyListeners();
  }

  set tags(List<Tag> newTags) {
    _tags = newTags;
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

  void changeUserInfo(String key, dynamic value) {
    if (_loginResponse == null) return;

    _loginResponse![key] = value;
    notifyListeners();
  }

  void setMessageList(String message) {
    _messageList.add(message);
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
    // TODO: 중복된 이름의 태그 -> 하나만 존재해야됨, 동일한거 두개 생김
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    if (content.title == "") {
      content.title = tr("content_default_title");
    }

    ApiResponse<Map<String, dynamic>> c =
        await saveContent(content, _loginResponse!["id"], accessToken!);

    if (c.success) {
      Map<String, dynamic> responseMap = c.data!;

      int newContentId = responseMap["id"];
      List<Tag> tags = responseMap["tags"];

      content.id = newContentId; // -1이었던걸 변경

      if (content.bookmark) {
        _bookmarkedSet.add(newContentId);
        _tagContentsMap["bookmark"]!.insert(0, content);
      }
      await pvFetchUserAllContents();

      for (var t in tags) {
        if (_tags.contains(t) == false) {
          _tags.insert(0, t);
        }

        _idTagNameMap[t.id] = t.tagName;

        if (_tagContentsMap[t.tagName] == null) {
          _tagContentsMap[t.tagName] = [];
        }
        _tagContentsMap[t.tagName]!.insert(0, content);
        await pvFetchUserTagContents(t.id, t.tagName);
      }

      notifyListeners();
    }
  }

  Future<void> pvEditContent(
      List<String> beforeTags, Content content, int contentId) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<Map<String, dynamic>> c = await editContent(
        content, contentId, _loginResponse!["id"], accessToken!);

    if (c.success) {
      Map<String, dynamic> responseMap = c.data!;

      // 아래 tags는 content의 모든 tags
      List<Tag> tags = (responseMap["tags"] as List<dynamic>)
          .map((tag) => Tag.fromJson(tag))
          .toList();

      for (var tagName in beforeTags) {
        bool isDeleted = !tags.any((tag) => tag.tagName == tagName);

        if (isDeleted) {
          List<Content> contents = _tagContentsMap[tagName] ?? [];
          contents.removeWhere((c) => c.id == content.id);

          // home screen tag bar에서도 없애줘야됨
          List<String>? fixedTags = prefs.getStringList("fixed_tags");
          if (fixedTags != null) {
            fixedTags.remove(tagName);
            await prefs.setStringList("fixed_tags", fixedTags);
          }

          if (contents.isEmpty) {
            _tagContentsMap.remove(tagName);

            _tags.removeWhere((tag) => tag.tagName == tagName);
          } else {
            _tagContentsMap[tagName] = contents;
          }
        }
      }

      await pvFetchUserTags();
      for (var tag in tags) {
        await pvFetchUserTagContents(tag.id, tag.tagName);
      }

      if (bookmarkedSet.contains(contentId) == true) {
        // 기존에 북마크에 있던 컨텐츠면, 북마크 부분 refresh
        await pvFetchUserBookmarkedContents();
      }
      await pvFetchUserAllContents();

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

      await pvFetchUserTags();
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

      await pvFetchUserBookmarkedContents();
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
      await pvFetchUserTags();
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> pvUpdateTag(int tagId, String tagName, Color color) async {
    if (_loginResponse == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> t = await updateTag(
        _loginResponse!["id"], tagId, tagName, color, accessToken!);

    if (t.success) {
      for (var tag in _tags) {
        if (tag.id == tagId) {
          tag.tagName = tagName;
          tag.color = color;
          break;
        }
      }
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<void> pvFetchArticlesLimited(String categoryName,
      {bool isInitial = false}) async {
    if (_loginResponse == null) return;

    int offset = isInitial ? 0 : _categoryOffsetMap[categoryName] ?? 0;

    ApiResponse<List<Article>> result;
    if (categoryName == "owned") {
      result = await fetchUserArticlesLimited(_loginResponse!["id"],
          _articleLimit, offset, _loginResponse!["access_token"]);
    } else {
      result = await fetchCategoryArticles(
          _articleLimit, offset, categoryName, _loginResponse!["access_token"]);
    }

    if (result.success) {
      if (isInitial) {
        _categoryArticlesMap[categoryName] = result.data!;
      } else {
        _categoryArticlesMap[categoryName]?.addAll(result.data!);
      }

      _categoryOffsetMap[categoryName] = offset + result.data!.length;
      _hasMoreByCategory[categoryName] = result.data!.length == _articleLimit;
    }
    notifyListeners();
  }

  Future<void> pvPostArticle(String title, String body, List<String> tags,
      String encodedContent) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> a = await postArticle(
        _loginResponse!["id"], title, body, encodedContent, tags, accessToken!);

    if (a.success) {
      // TODO pvFetchRefreshedArticles();
      await pvFetchArticlesLimited("all", isInitial: true);
      await pvFetchArticlesLimited(_currentCategoryList[_currentCategory],
          isInitial: true);
    }
  }

  Future<void> pvPutArticle(
    int articleId,
    String title,
    String body,
    List<String> tags,
  ) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> a = await putArticle(
        _loginResponse!["id"], articleId, title, body, tags, accessToken!);

    if (a.success) {
      await pvFetchArticlesLimited("all", isInitial: true);
      await pvFetchArticlesLimited(_currentCategoryList[_currentCategory],
          isInitial: true);
    }
  }

  Future<void> pvDeleteArticle(int articleId) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> a =
        await deleteArticle(_loginResponse!["id"], articleId, accessToken!);

    if (a.success) {
      // TODO pvFetchRefreshedArticles();
      await pvFetchArticlesLimited("all", isInitial: true);
      await pvFetchArticlesLimited(_currentCategoryList[_currentCategory],
          isInitial: true);
    }
  }

  Future<void> pvDownloadArticle(String newTagName, int articleId) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> a = await downloadArticle(
        _loginResponse!["id"], newTagName, articleId, accessToken!);

    if (a.success) {
      await pvFetchUserAllContents();
      await pvFetchUserTags();
      await pvFetchUserTagContents(a.data!, newTagName);
      notifyListeners();
    }
  }

  Future<void> pvDeleteComment(int commentId) async {
    if (_loginResponse == null) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access_token");

    ApiResponse<int> a = await deleteArticleComment(commentId, accessToken!);

    if (a.success) {
      // TODO pvFetchRefreshedArticles();
      notifyListeners();
    }
  }

  Future<void> setInitialSetting(Map<String, dynamic> loginResponse) async {
    _loginResponse = loginResponse;
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() async {
    _themeMode =
        (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: whiteBackgroundColor,
      primaryColor: mainColor,
      appBarTheme: AppBarTheme(
        backgroundColor: whiteBackgroundColor,
        foregroundColor: lightBlackBackgroundColor,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: blackBackgroundColor),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: whiteBackgroundColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBarColor,
        contentTextStyle: TextStyle(color: whiteBackgroundColor),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: lightBlackBackgroundColor,
      primaryColor: mainColor,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBlackBackgroundColor,
        foregroundColor: whiteBackgroundColor,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: whiteBackgroundColor),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: lightBlackBackgroundColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBarColor,
        contentTextStyle: TextStyle(color: whiteBackgroundColor),
      ),
    );
  }
}

class SharedDataController extends ChangeNotifier {
  SharedMedia? _media;

  SharedMedia? get media => _media;

  void setMedia(SharedMedia media) {
    _media = media;
    notifyListeners();
  }

  void clear() {
    _media = null;
  }
}

int binarySearchInsertIndex(List<Content> list, Content target) {
  int low = 0;
  int high = list.length;

  while (low < high) {
    int mid = (low + high) >> 1;

    if (target.id < list[mid].id) {
      high = mid;
    } else {
      low = mid + 1;
    }
  }

  return low;
}
