import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:tagify/global.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  PremiumUpgradeScreenState createState() => PremiumUpgradeScreenState();
}

class PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  @override
  Widget build(BuildContext context) {
    final double widgetWidth = MediaQuery.of(context).size.width * (0.85);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Align(
          alignment: Alignment.centerLeft,
          child: GlobalText(
            localizeText: "프리미엄 멤버십",
            textSize: 20.0,
            isBold: true,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: widgetWidth,
            child: Column(
              children: [
                const SizedBox(height: 30.0),
                Container(
                  height: 130.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 3),
                        blurRadius: 4.0,
                        color: Colors.grey[300]!,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    width: double.infinity,
                    child: Row(
                      children: [
                        SizedBox(
                          width: widgetWidth * (0.65),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GlobalText(
                                localizeText:
                                    "프리미엄 멤버십으로 업그레이드", // TODO: localization
                                textSize: 17.0,
                                isBold: true,
                              ),
                              const SizedBox(height: 10.0),
                              GlobalText(
                                localizeText: "프리미엄으로 업그레이드해서 더많은 기능을 이용해보세요!",
                                textSize: 14.0,
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   child: Padding(
                        //     padding: EdgeInsets.all(10.0),
                        //     child: Container(
                        //       padding: EdgeInsets.all(0.0),
                        //       decoration: BoxDecoration(
                        //         color: whiteBackgroundColor,
                        //         borderRadius: BorderRadius.circular(20.0),
                        //         boxShadow: [
                        //           BoxShadow(
                        //             offset: Offset(0, 3),
                        //             blurRadius: 4.0,
                        //             color: Colors.grey[300]!,
                        //           ),
                        //         ],
                        //       ),
                        //       child: Image.asset(
                        //         "assets/app_main_icons_1024_1024.png",
                        //         color: const Color.fromARGB(255, 255, 213, 29),
                        //         colorBlendMode: BlendMode.srcIn,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Container(
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 3),
                                    blurRadius: 4.0,
                                    color: Colors.grey[300]!,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    "assets/app_main_icons_1024_1024.png",
                                    color: mainColor,
                                    colorBlendMode: BlendMode.srcIn,
                                    fit: BoxFit.cover,
                                  ),
                                  const GlitterOverlay(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50.0),
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GlobalText(
                        localizeText: "프리미엄 혜택",
                        textSize: 15.0,
                        isBold: true,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GlobalText(
                          localizeText: "1. 생성 가능한 태그 수 제한이 해제됩니다!",
                          textSize: 15.0),
                    ),
                    const SizedBox(height: 6.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GlobalText(
                          localizeText: "2. 태그 색상을 자유롭게 바꿀 수 있습니다!",
                          textSize: 15.0),
                    ),
                    const SizedBox(height: 6.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GlobalText(
                          localizeText: "3. 추후 더 많은 혜택으로 찾아오겠습니다.",
                          textSize: 15.0),
                    ),
                    const SizedBox(height: 30.0),
                    Container(
                      width: widgetWidth,
                      height: 150.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color.fromARGB(94, 171, 228, 255),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: widgetWidth * (0.6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GlobalText(
                                    localizeText: "프리미엄 멤버쉽 구매",
                                    textSize: 15.0),
                                GlobalText(
                                    localizeText: "최초 1회 구매시 영구 회원",
                                    textSize: 15.0),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            width: 0.5,
                            indent: 15.0,
                            endIndent: 15.0,
                            thickness: 0.5,
                          ),
                          Expanded(
                            child: Padding(
                              // padding: EdgeInsets.all(10.0),
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              child: GlobalText(
                                localizeText: "4,900원",
                                textSize: 28.0,
                                isBold: true,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40.0),

                    // 인앱 결제 구매 버튼
                    GestureDetector(
                      onTap: () {
                        // TODO: 결제화면으로 넘어가기 (in-app-purchase)
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: widgetWidth,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 3),
                              blurRadius: 4.0,
                              color: Colors.grey[300]!,
                            ),
                          ],
                        ),
                        child: GlobalText(
                          localizeText: "프리미엄 회원으로 업그레이드하기",
                          textSize: 15.0,
                          isBold: true,
                          textColor: whiteBackgroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlitterOverlay extends StatelessWidget {
  const GlitterOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GlitterPainter(),
      size: Size.square(75.0),
    );
  }
}

class _GlitterPainter extends CustomPainter {
  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(204, 255, 214, 11)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 30; i++) {
      final dx = _random.nextDouble() * size.width;
      final dy = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 2.5 + 0.5;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
