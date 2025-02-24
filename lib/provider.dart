import 'package:flutter/material.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/components/contents/common.dart';

class TagifyProvider extends ChangeNotifier {
  int? _userId;
  String _currentTag = "all";
  List<Content> _contents = [];

  String get currentTag => _currentTag;
  List<Content> get contents => _contents;

  void setUserId(int userId) {
    _userId = userId;
    fetchContents();
  }

  void setTag(String newTag) {
    _currentTag = newTag;
    fetchContents();
    notifyListeners();
  }

  Future<void> fetchContents() async {
    if (_userId == null) return;

    ApiResponse<List<Content>> response;
    switch (_currentTag) {
      case "all":
        response = await fetchUserContents(_userId!);
        break;
      case "bookmark":
        response = await fetchBookmarkContents(_userId!);
        break;
      default:
        // TODO: 특정 태그 콘텐츠만 불러오기
        response = await fetchUserContents(_userId!);
        break;
    }

    if (response.success) {
      _contents = response.data ?? [];
      notifyListeners();
    }
  }
}
