import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tagify/api/content.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
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
  final uri = Uri.tryParse(url);
  if (uri == null) return false;

  final host = uri.host;
  final path = uri.path;

  // 영상 URL인지 확인
  if (host.contains('youtu.be')) {
    return true;
  }

  if (host.contains('youtube.com')) {
    // 음악
    if (host.contains("music")) return true;

    // 영상
    if (path == "/watch" && uri.queryParameters.containsKey('v')) return true;

    // Shorts
    if (path.startsWith("/shorts")) return true;

    // Live 영상
    if (path.startsWith("/live")) return true;

    // 커뮤니티 글
    if (path.startsWith("/post/") || path.contains("/community")) {
      return false;
    }
  }

  return false;
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

bool isValidUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasAbsolutePath;
}

Future<void> checkSharedItems(BuildContext context) async {
  final provider = Provider.of<TagifyProvider>(context, listen: false);
  const platform = MethodChannel("com.ellipsoid.tagi/share");

  try {
    final dynamic result = await platform.invokeMethod("getSharedData");

    if (result is! List) {
      debugPrint("Unexpected shared data format: $result");
      return;
    }

    for (final item in result) {
      if (item is Map) {
        final String? title = item["title"] as String?;
        final String? url = item["url"] as String?;
        final String? tagString = item["tags"] as String?;

        if (url != null && url.isNotEmpty && tagString != null) {
          final c = await analyzeContent(
            provider.loginResponse!["id"],
            url,
            "ko",
            isVideo(url) ? "video" : "post",
            provider.loginResponse!["access_token"],
          );

          if (c.success) {
            Content content = c.data!;

            final List<String> tags = tagString
                .split(",")
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList();

            List<String> finalTags = tags.isEmpty ? [tr("util_share")] : tags;
            content.tags = finalTags;
            content.title =
                title != null && title != "" ? title : c.data!.title;

            if (provider.loginResponse!["is_premium"] == false) {
              // 일반 회원이 컨텐츠당 태그를 4개 이상 만드려고 하면
              if (finalTags.length >= 4) {
                finalTags = finalTags.sublist(0, 4);
              }
            }

            // 중복되지 않은 새 태그만 추출
            final newTags = finalTags
                .where((tag) =>
                    !provider.tags.any((existing) => existing.tagName == tag))
                .toList();

            final totalTagCount = provider.tags.length + newTags.length;

            if (totalTagCount > nonePremiumTagUpperBound &&
                provider.loginResponse!["is_premium"] == false) {
              // 프리미엄 회원 아닌데, 태그 제한 초과시 무시
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: snackBarColor,
                  content: GlobalText(
                      localizeText: "no_premium_tag_count_error",
                      textSize: 15.0),
                  duration: Duration(seconds: 1),
                ),
              );
              return;
            }

            await provider.pvSaveContent(content);
          }
        }
      }
    }
  } catch (e) {
    debugPrint("Shared Items Fetch Failed: $e");
  }
}
