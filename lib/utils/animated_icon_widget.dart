import 'package:flutter/material.dart';
import 'package:tagify/global.dart';

class LuxInfiniteFlowIcon extends StatefulWidget {
  final double iconWidth;
  final Color iconColor;

  const LuxInfiniteFlowIcon(
      {super.key, this.iconColor = mainColor, required this.iconWidth});

  @override
  State<LuxInfiniteFlowIcon> createState() => _LuxInfiniteFlowIconState();
}

class _LuxInfiniteFlowIconState extends State<LuxInfiniteFlowIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.iconWidth;
    final height = widget.iconWidth;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.iconColor,
                const Color.fromARGB(255, 255, 133, 26),
                widget.iconColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              tileMode: TileMode.repeated,
              transform:
                  _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          blendMode: BlendMode.srcIn,
          child: child,
        );
      },
      child: Image.asset(
        "assets/app_main_icons_1024_1024.png",
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    // X축으로 슬라이딩 이동 (0.0 ~ 1.0)
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
