import 'package:flutter/material.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/api/tag.dart';
import 'package:tagify/components/contents/common.dart';

class TagifyProvider extends ChangeNotifier {
  int? _userId;
  String _currentTag = "all";
  String _currentPage = "home";
  List<Content> _contents = [];
  List<Tag> _tags = [];
  Map<String, dynamic>? _loginResponse;
  Map<String, int> _tagNameIdMap = {};
  int _tagScreenSelectedGrid = 2;

  String get currentTag => _currentTag;
  String get currentPage => _currentPage;
  List<Content> get contents => _contents;
  List<Tag> get tags => _tags;
  Map<String, dynamic>? get loginResponse => _loginResponse;
  int get selectedGrid => _tagScreenSelectedGrid;

  void setCurrentPage(String newPage) {
    _currentPage = newPage;
    // notifyListeners();
  }

  void setSelectedGrid(int newGrid) {
    _tagScreenSelectedGrid = newGrid;
    notifyListeners();
  }

  Future<void> setUserId(int userId) async {
    _userId = userId;
    await fetchContents();
    await fetchTags();
  }

  Future<void> setUserInfo(Map<String, dynamic> loginResponse) async {
    _loginResponse = loginResponse;
    await fetchContents();
    await fetchTags();
  }

  Future<void> setTag(String newTag) async {
    _currentTag = newTag;
    await fetchContents();
  }

  Future<void> fetchContents() async {
    if (_userId == null) return;

    ApiResponse<List<Content>> contentsResponse;
    switch (_currentTag) {
      case "all":
        contentsResponse = await fetchUserContents(_userId!);
        break;
      case "bookmark":
        contentsResponse = await fetchBookmarkContents(_userId!);
        break;
      default:
        contentsResponse =
            await fetchUserTagAllContents(_tagNameIdMap[_currentTag]!);
        break;
    }

    if (contentsResponse.success) {
      _contents = contentsResponse.data ?? [];
      notifyListeners();
    }
  }

  Future<void> fetchTags() async {
    if (_userId == null) return;

    ApiResponse<List<Tag>> tagsResponse;
    tagsResponse = await fetchUserTags(_userId!);

    if (tagsResponse.success) {
      _tags = tagsResponse.data ?? [];

      for (var tag in tags) {
        _tagNameIdMap[tag.tagName] = tag.id;
      }
      notifyListeners();
    }
  }
}
