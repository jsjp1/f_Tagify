import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SmartNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, String, Object)? errorWidget;
  final Widget? placeholder;

  const SmartNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.errorWidget,
    this.placeholder,
  });

  bool get isSvg => url.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isSvg) {
      return SvgPicture.network(
        url,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => placeholder ?? const SizedBox.shrink(),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) => placeholder ?? const SizedBox.shrink(),
        errorWidget: (context, url, error) {
          debugPrint("🔥 SmartNetworkImage: errorWidget triggered");
          if (errorWidget != null) {
            return errorWidget!(context, url, error);
          }
          return const SizedBox.shrink();
        },
      );
    }
  }
}
