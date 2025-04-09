import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class TagShimmer extends StatefulWidget {
  final bool isDarkMode;

  const TagShimmer({super.key, required this.isDarkMode});

  @override
  State<TagShimmer> createState() => _TagShimmerState();
}

class _TagShimmerState extends State<TagShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDarkMode
        ? const Color.fromARGB(255, 43, 43, 43)
        : const Color.fromARGB(255, 232, 232, 232);
    final highlightColor = widget.isDarkMode
        ? const Color.fromARGB(255, 69, 69, 69)
        : const Color.fromARGB(255, 245, 245, 245);

    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.1, 0.5, 0.8],
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                transform: _SlidingGradientTransform(_controller.value),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const SizedBox(
                width: 40,
                height: 5,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ArticleInstanceShimmer extends StatefulWidget {
  final bool isDarkMode;

  const ArticleInstanceShimmer({super.key, required this.isDarkMode});

  @override
  State<ArticleInstanceShimmer> createState() => _ArticleInstanceShimmerState();
}

class _ArticleInstanceShimmerState extends State<ArticleInstanceShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildShimmerBox({
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
  }) {
    final baseColor = widget.isDarkMode
        ? const Color.fromARGB(255, 43, 43, 43)
        : const Color.fromARGB(255, 232, 232, 232);
    final highlightColor = widget.isDarkMode
        ? const Color.fromARGB(255, 69, 69, 69)
        : const Color.fromARGB(255, 245, 245, 245);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.1, 0.5, 0.8],
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                colors: [baseColor, highlightColor, baseColor],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: SizedBox(
        height: articleInstanceThumbnailHeight,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: SizedBox(
                height: articleInstanceThumbnailHeight,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildShimmerBox(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 오른쪽 title, body, ...부분
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(
                    height: 14.0,
                  ),
                  const SizedBox(height: 8),
                  _buildShimmerBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 12.0,
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    children: List.generate(
                      3,
                      (_) => _buildShimmerBox(
                        width: 30,
                        height: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
