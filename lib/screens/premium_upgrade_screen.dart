import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/api/user.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  PremiumUpgradeScreenState createState() => PremiumUpgradeScreenState();
}

class PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  String priceString = "";
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _subscription = _iap.purchaseStream.listen(_onPurchaseUpdated);
    _initIAP();
  }

  Future<void> _initIAP() async {
    final bool available = await _iap.isAvailable();

    if (!available) {
      setState(() {
        _isAvailable = false;
        _isLoading = false;
      });
      return;
    }

    const Set<String> _kIds = {'tagify', "tagify_premium_4400"};
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_kIds);

    if (response.error == null && response.productDetails.isNotEmpty) {
      setState(() {
        _isAvailable = true;
        _products = response.productDetails;
        _isLoading = false;
        priceString = _products.first.price;
      });
    }
  }

  void _buyPremium() async {
    if (_products.isEmpty) return;

    final ProductDetails product = _products.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // TODO
  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // 실제 unlock 처리
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }

        // TODO: 프리미엄 상태 반영
        ApiResponse<int> result = await updatePremiumStatus(
            provider.loginResponse!["id"],
            provider.loginResponse!["access_token"]);

        if (result.success) {
          // 성공하면 provider에 프리미엄 상태 반영
          provider.loginResponse!["is_premium"] = true;

          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("프리미엄 가입 완료"),
                  content: const Text("Tagify 프리미엄에 가입되었습니다!\n감사합니다 🙏"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("확인"),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          // 실패 처리
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("업데이트 실패"),
                  content: const Text("프리미엄 상태 반영에 실패했습니다.\n잠시 후 다시 시도해주세요."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("확인"),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double widgetWidth = MediaQuery.of(context).size.width * (0.85);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: widgetWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(
                    width: widgetWidth,
                    height: MediaQuery.of(context).size.height * (0.12),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 37, 37, 37)
                                  : const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode
                                      ? darkContentInstanceBoxShadowColor
                                      : contentInstanceBoxShadowColor,
                                  blurRadius: 5.0,
                                  spreadRadius: 0.01,
                                  offset: Offset(0, 5),
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
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 25.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GlobalText(
                              localizeText: "Tagify Premium",
                              textSize: 22.0,
                              isBold: true,
                              letterSpacing: -0.5,
                            ),
                            Row(
                              children: [
                                GlobalText(
                                  localizeText: "Collect, Tag, Explore  ",
                                  textSize: 15.0,
                                  localization: false,
                                ),
                                GlobalText(
                                  localizeText: "Unlimited",
                                  textSize: 16.0,
                                  isBold: true,
                                  localization: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GlobalText(
                          localizeText:
                              "premium_upgrade_screen_with_premium_text",
                          textSize: 15.0,
                          isBold: true,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.local_offer,
                                color: isDarkMode
                                    ? Colors.yellowAccent
                                    : Colors.orangeAccent,
                                size: 20.0),
                            const SizedBox(width: 15.0),
                            GlobalText(
                              localizeText: "premium_upgrade_screen_1",
                              textSize: 17.0,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GlobalText(
                            localizeText: "premium_upgrade_screen_1_detail",
                            textSize: 15.0),
                      ),
                      const SizedBox(height: 15.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.lock_open,
                                color: isDarkMode
                                    ? Colors.yellowAccent
                                    : Colors.orangeAccent,
                                size: 20.0),
                            const SizedBox(width: 15.0),
                            GlobalText(
                              localizeText: "premium_upgrade_screen_2",
                              textSize: 17.0,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GlobalText(
                            localizeText: "premium_upgrade_screen_2_detail",
                            textSize: 15.0),
                      ),
                      const SizedBox(height: 15.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.palette,
                                color: isDarkMode
                                    ? Colors.yellowAccent
                                    : Colors.orangeAccent,
                                size: 20.0),
                            const SizedBox(width: 15.0),
                            GlobalText(
                              localizeText: "premium_upgrade_screen_3",
                              textSize: 17.0,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GlobalText(
                            localizeText: "premium_upgrade_screen_3_detail",
                            textSize: 15.0),
                      ),
                      const SizedBox(height: 30.0),
                      const Divider(
                        thickness: 1.0,
                        height: 5.0,
                      ),
                      const SizedBox(height: 30.0),
                    ],
                  ),
                  Container(
                    width: widgetWidth,
                    height: 130.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: mainColor, width: 3.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 0.0),
                          child: GlobalText(
                            localizeText:
                                "premium_upgrade_screen_upgrade_text_1",
                            textSize: 20.0,
                            isBold: true,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 0.0),
                          child: GlobalText(
                            // TODO: ProductDetails.price로 변경
                            localizeText: priceString,
                            textSize: 21.5,
                            isBold: true,
                            localization: false,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 0.0),
                          child: GlobalText(
                            localizeText:
                                "premium_upgrade_screen_upgrade_text_2",
                            textSize: 15.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  // 인앱 결제 구매 버튼
                  GestureDetector(
                    onTap: _buyPremium,
                    child: Container(
                      alignment: Alignment.center,
                      width: widgetWidth,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? darkContentInstanceBoxShadowColor
                                : contentInstanceBoxShadowColor,
                            blurRadius: 5.0,
                            spreadRadius: 0.01,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: GlobalText(
                        localizeText:
                            "premium_upgrade_screen_upgrade_button_text",
                        textSize: 15.0,
                        isBold: true,
                        textColor: whiteBackgroundColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 200.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
