import 'package:flutter/material.dart';

class AnimatedDrawerLayout extends StatefulWidget {
  final Widget mainContent;
  final Widget leftDrawerContent;
  final Widget rightDrawerContent;

  const AnimatedDrawerLayout({
    super.key,
    required this.mainContent,
    required this.leftDrawerContent,
    required this.rightDrawerContent,
  });

  @override
  AnimatedDrawerLayoutState createState() => AnimatedDrawerLayoutState();
}

class AnimatedDrawerLayoutState extends State<AnimatedDrawerLayout>
    with SingleTickerProviderStateMixin {
  double _leftOffset = 0.0;
  double _rightOffset = 0.0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 230),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCirc,
      ),
    );
  }

  void toggleLeftMenu() {
    setState(() {
      _leftOffset =
          (_leftOffset == 0.0) ? MediaQuery.of(context).size.width * 0.45 : 0.0;
    });

    if (_leftOffset == 0.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void toggleRightMenu() {
    setState(() {
      _rightOffset = (_rightOffset == 0.0)
          ? -MediaQuery.of(context).size.width * 0.7
          : 0.0;
    });

    if (_rightOffset == 0.0) {
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
    double screenWidth = MediaQuery.of(context).size.width;
    double leftDrawerWidth = screenWidth * 0.45;
    double rightDrawerWidth = screenWidth * 0.7;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (_leftOffset != 0.0 || _rightOffset != 0.0) {
              setState(() {
                _leftOffset = 0.0;
                _rightOffset = 0.0;
              });
              _animationController.reverse();
            }
          },
        ),
        // 메인 컨텐츠
        AnimatedPositioned(
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeInOutCirc,
          left: _leftOffset != 0.0 ? _leftOffset : _rightOffset,
          right: _rightOffset != 0.0 ? -_rightOffset : -_leftOffset,
          child: SizedBox(
            width: screenWidth,
            height: MediaQuery.of(context).size.height,
            child: IgnorePointer(
              ignoring: _leftOffset != 0.0 || _rightOffset != 0.0,
              child: widget.mainContent,
            ),
          ),
        ),
        // 왼쪽 드로어
        AnimatedPositioned(
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeInOutCirc,
          left: _leftOffset == 0.0 ? -leftDrawerWidth : 0.0,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              width: leftDrawerWidth,
              height: MediaQuery.of(context).size.height,
              child: widget.leftDrawerContent,
            ),
          ),
        ),
        // 오른쪽 드로어
        AnimatedPositioned(
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeInOutCirc,
          right: _rightOffset == 0.0 ? -rightDrawerWidth : 0.0,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              width: rightDrawerWidth,
              height: MediaQuery.of(context).size.height,
              child: widget.rightDrawerContent,
            ),
          ),
        ),
      ],
    );
  }
}
