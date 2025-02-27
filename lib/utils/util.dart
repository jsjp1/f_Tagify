import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
