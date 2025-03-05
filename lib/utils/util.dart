import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tagify/components/contents/common.dart';

String secTimeConvert(int time) {
  int hour = time ~/ 3600;
  int min = (time % 3600) ~/ 60;
  int sec = time % 60;

  if (hour > 0) {
    return "$hour:${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  } else if (min > 0) {
    return "$min:${sec.toString().padLeft(2, '0')}";
  } else {
    return sec.toString();
  }
}

String datetimeToYMD(DateTime dt) {
  return DateFormat("yyyy-MM-dd HH:mm").format(dt);
}

bool isVideo(String url) {
  return url.contains("youtu");
}

String extractVideoId(String url) {
  Uri uri = Uri.parse(url);
  if (uri.queryParameters.containsKey('v')) {
    return uri.queryParameters['v']!;
  } else if (uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.last;
  }
  return "";
}

Future<void> launchContentUrl(String url) async {
  final Uri uri = Uri.parse(url);

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri'; // TODO
    }
  } catch (e) {
    debugPrint("$e");
  }
}

String encodeTaggedContentsToBase64(Map<String, dynamic> data) {
  String jsonString = jsonEncode(data);
  List<int> utf8Bytes = utf8.encode(jsonString);
  List<int> compressedBytes = GZipCodec().encode(utf8Bytes);

  String base64String = base64.encode(compressedBytes);

  return base64String;
}

Map<String, dynamic> decodeBase64AndDecompress(String base64String) {
  List<int> decodeBytes = base64.decode(base64String);
  List<int> decompressedBytes = GZipCodec().decode(decodeBytes);

  String jsonString = utf8.decode(decompressedBytes);
  Map<String, dynamic> json = jsonDecode(jsonString);

  return json;
}

Map<String, dynamic> contentListToMap(List<Content> contents) {
  return {
    "contents": contents.map((content) => content.toJson()).toList(),
  };
}
