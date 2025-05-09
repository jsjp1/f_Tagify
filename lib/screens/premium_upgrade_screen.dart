import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/user.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/home_screen.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  PremiumUpgradeScreenState createState() => PremiumUpgradeScreenState();
}

class PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  String priceString = "";
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;

    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription.cancel(),
      onError: (e) {
        debugPrint("Error while purchase updated: $e");
      },
    );
    _initIAP();

    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initIAP() async {
    final bool available = await _iap.isAvailable();

    if (!available) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    const Set<String> _kIds = {"tagify_premium.com.ellipsoid.tagi"};

    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_kIds);

      if (response.error == null && response.productDetails.isNotEmpty) {
        setState(() {
          _products = response.productDetails;
          _isLoading = false;

          priceString = _products.first.price;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _buyPremium() async {
    if (_products.isEmpty || _isPurchasing) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CupertinoActivityIndicator(
              color: whiteBackgroundColor,
            ),
          );
        },
      );

      await Future.delayed(const Duration(seconds: 1));

      final ProductDetails product = _products.first;
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("ERROR: $e");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: snackBarColor,
            content: GlobalText(
              localizeText: "premium_upgrade_screen_pay_error_text",
              textSize: 15.0,
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isPurchasing = false;
      });
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    for (final purchase in purchases) {
      try {
        switch (purchase.status) {
          case PurchaseStatus.pending:
            break;

          case PurchaseStatus.error:
            await _iap.completePurchase(purchase);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  backgroundColor: snackBarColor,
                  content: GlobalText(
                    localizeText: "premium_upgrade_screen_pay_error_text",
                    textSize: 15.0,
                  ),
                ),
              );
            }
            break;

          case PurchaseStatus.canceled:
            await _iap.completePurchase(purchase);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  backgroundColor: snackBarColor,
                  content: GlobalText(
                    localizeText: "premium_upgrade_screen_pay_cancel_text",
                    textSize: 15.0,
                  ),
                ),
              );
            }
            break;

          case PurchaseStatus.purchased:
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }

            if (context.mounted) {
              await _applyPremium(context, provider, prefs);
            }
            break;

          case PurchaseStatus.restored:
            // restoredCount++;

            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }

            if (context.mounted) {
              await _applyPremium(context, provider, prefs);
            }
            break;
        }
      } catch (e) {
        if (context.mounted) {
          await showPremiumFailureDialog(context);
        }
      }
    }

    // 복원할 구매 내역이 없는 경우
    // if (restoredCount == 0 &&
    //     purchases.any((p) => p.status == PurchaseStatus.restored)) {
    //   if (context.mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         duration: const Duration(seconds: 1),
    //         backgroundColor: snackBarColor,
    //         content: GlobalText(
    //           localizeText: "premium_upgrade_screen_no_restore_text",
    //           textSize: 15.0,
    //         ),
    //       ),
    //     );
    //   }
    // }
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
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GlobalText(
                                localizeText: "Tagify Premium",
                                textSize: 22.0,
                                isBold: true,
                                letterSpacing: -0.5,
                                localization: false,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GlobalText(
                                    localizeText: "Collect, Tag, Explore  ",
                                    textSize: 13.0,
                                    localization: false,
                                  ),
                                  GlobalText(
                                    localizeText: "Unlimited",
                                    textSize: 14.0,
                                    isBold: true,
                                    localization: false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            GlobalText(
                              localizeText: "🚀",
                              textSize: 20.0,
                              localization: false,
                            ),
                            const SizedBox(width: 10.0),
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
                            GlobalText(
                              localizeText: "🚀",
                              textSize: 20.0,
                              localization: false,
                            ),
                            const SizedBox(width: 10.0),
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
                            GlobalText(
                              localizeText: "🚀",
                              textSize: 20.0,
                              localization: false,
                            ),
                            const SizedBox(width: 10.0),
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
                      const SizedBox(height: 15.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            GlobalText(
                              localizeText: "🚀",
                              textSize: 20.0,
                              localization: false,
                            ),
                            const SizedBox(width: 10.0),
                            GlobalText(
                              localizeText: "premium_upgrade_screen_4",
                              textSize: 17.0,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GlobalText(
                            localizeText: "premium_upgrade_screen_4_detail",
                            textSize: 15.0),
                      ),
                      const SizedBox(height: 30.0),
                      const Divider(
                        thickness: 1.0,
                        height: 5.0,
                      ),
                      const SizedBox(height: 15.0),
                    ],
                  ),
                  Center(
                    child: GlobalText(
                      localizeText: "premium_upgrade_screen_lifetime_text",
                      textSize: 18.0,
                      isBold: true,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GlobalText(
                            localizeText:
                                "premium_upgrade_screen_upgrade_button_text",
                            textSize: 18.0,
                            isBold: true,
                            textColor: whiteBackgroundColor,
                          ),
                          const SizedBox(width: 10.0),
                          _isLoading
                              ? const CupertinoActivityIndicator(
                                  color: whiteBackgroundColor,
                                )
                              : GlobalText(
                                  localizeText: priceString,
                                  textSize: 19.0,
                                  textColor: whiteBackgroundColor,
                                  isBold: true,
                                  localization: false,
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  GestureDetector(
                    onTap: () async {
                      if (await _iap.isAvailable() == false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: snackBarColor,
                            content: GlobalText(
                                localizeText:
                                    "premium_upgrade_screen_store_connect_fail_text",
                                textSize: 15.0),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CupertinoActivityIndicator(
                                color: whiteBackgroundColor),
                          );
                        },
                      );

                      try {
                        await _iap.restorePurchases();
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: snackBarColor,
                              content: GlobalText(
                                  localizeText:
                                      "premium_upgrade_screen_restore_cancel_text",
                                  textSize: 15.0),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: GlobalText(
                      localizeText: "premium_upgrade_screen_rebuy_text",
                      textSize: 15.0,
                      textColor: Colors.grey[500],
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
}

Future<void> _applyPremium(BuildContext context, TagifyProvider provider,
    SharedPreferences prefs) async {
  // 구매 성공시 db에 반영하는 작업
  ApiResponse<int> result = await updatePremiumStatus(
      provider.loginResponse!["id"], provider.loginResponse!["access_token"]);

  if (result.success) {
    provider.changeUserInfo("is_premium", true);

    final stored = prefs.getString("loginResponse");
    if (stored != null) {
      final updated = jsonDecode(stored);
      updated["is_premium"] = true;
      await prefs.setString("loginResponse", jsonEncode(updated));
    }

    if (context.mounted) {
      await showPremiumSuccessDialog(context, provider.loginResponse!);
    }
  } else {
    if (context.mounted) {
      await showPremiumFailureDialog(context);
    }
  }
}

Future<void> showPremiumSuccessDialog(
    BuildContext context, Map<String, dynamic> loginResponse) async {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  await showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: GlobalText(
          localizeText: "premium_upgrade_screen_success_title",
          textSize: 20.0,
          textColor: isDarkMode ? whiteBackgroundColor : blackBackgroundColor,
          isBold: true,
        ),
        content: GlobalText(
          localizeText: "premium_upgrade_screen_success_message",
          textSize: 15.0,
        ),
        actions: [
          CupertinoDialogAction(
            child: GlobalText(
              localizeText: "premium_upgrade_screen_confirm_button_text",
              textSize: 15.0,
              textColor: mainColor,
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    loginResponse: loginResponse,
                  ),
                ),
                (route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}

Future<void> showPremiumFailureDialog(BuildContext context) async {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  await showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: GlobalText(
          localizeText: "premium_upgrade_screen_failed_title",
          textSize: 20.0,
          textColor: isDarkMode ? whiteBackgroundColor : blackBackgroundColor,
          isBold: true,
        ),
        content: GlobalText(
          localizeText: "premium_upgrade_screen_failed_message",
          textSize: 15.0,
        ),
        actions: [
          CupertinoDialogAction(
            child: GlobalText(
              localizeText: "premium_upgrade_screen_confirm_button_text",
              textSize: 15.0,
              textColor: mainColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
