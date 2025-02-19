import 'package:flutter/material.dart';

class TagifyProvider extends ChangeNotifier {
  String currentTag = "all";

  void changeTag(String newTag) {
    currentTag = newTag;
    notifyListeners();
  }
}
