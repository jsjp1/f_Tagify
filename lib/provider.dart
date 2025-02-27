import 'package:flutter/material.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/api/tag.dart';
import 'package:tagify/components/contents/common.dart';

class TagifyProvider extends ChangeNotifier {
  int? _userId;
  String _currentTag = "all";
  List<Content> _contents = [];
  List<Tag> _tags = [];
  Map<String, dynamic>? _loginResponse;
  Map<String, int> _tagNameIdMap = {};

  String get currentTag => _currentTag;
  List<Content> get contents => _contents;
  List<Tag> get tags => _tags;
  Map<String, dynamic>? get loginResponse => _loginResponse;

  void setUserId(int userId) {
    _userId = userId;
    fetchContents();
    fetchTags();
  }

  void setUserInfo(Map<String, dynamic> loginResponse) {
    _loginResponse = loginResponse;
    fetchContents();
    fetchTags();
  }

  void setTag(String newTag) {
    _currentTag = newTag;
    fetchContents();
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
