import 'package:flutter/material.dart';

class AnimatedDrawerLayout extends StatefulWidget {
  final Widget mainContent;
  final Widget drawerContent;

  const AnimatedDrawerLayout({
    super.key,
    required this.mainContent,
    required this.drawerContent,
  });

  @override
  AnimatedDrawerLayoutState createState() => AnimatedDrawerLayoutState();
}

class AnimatedDrawerLayoutState extends State<AnimatedDrawerLayout>
    with SingleTickerProviderStateMixin {
  double _offset = 0.0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 230));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCirc,
      ),
    );
  }

  void toggleMenu() {
    setState(() {
      _offset =
          (_offset == 0.0) ? -MediaQuery.of(context).size.width * (0.7) : 0.0;
    });

    if (_offset == 0.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (_offset != 0.0) {
              toggleMenu();
            }
          },
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: 230),
          curve: Curves.easeInOutCirc,
          left: _offset,
          right: -_offset,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: IgnorePointer(
              ignoring: _offset != 0.0,
              child: widget.mainContent,
            ),
          ),
        ),
        AnimatedPositioned(
          duration: _offset == 0.0
              ? Duration(milliseconds: 230)
              : Duration(milliseconds: 230),
          curve: Curves.easeInOutCirc,
          right:
              _offset == 0.0 ? -MediaQuery.of(context).size.width * (0.7) : 0.0,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * (0.7),
              child: widget.drawerContent,
            ),
          ),
        ),
      ],
    );
  }
}
