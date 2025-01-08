import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/pages/auth/profile_page.dart';
import 'package:build_growth_mobile/pages/financial/asset_detail_page.dart';
import 'package:build_growth_mobile/pages/financial/debt_detail_page.dart';
import 'package:build_growth_mobile/pages/financial/financial_page.dart';
import 'package:build_growth_mobile/pages/widget_tree/home_page.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialHelper {
  /// Unique identifier for the tutorial
  static final List<GlobalKey> financialKeys =
      List.generate(12, (_) => GlobalKey());
  static final List<GlobalKey> assetKeys =
      List.generate(12, (_) => GlobalKey());
  static final List<GlobalKey> debtKeys = List.generate(12, (_) => GlobalKey());
  static final List<GlobalKey> gptKeys = List.generate(12, (_) => GlobalKey());
  static final List<GlobalKey> contentKeys =
      List.generate(12, (_) => GlobalKey());
  static final List<GlobalKey> profileKeys =
      List.generate(12, (_) => GlobalKey());

  static bool isClicking = false;
  static bool isScrolling = false;

  /// Static TutorialCoachMark instance for shared usage
  static TutorialCoachMark? tutorialCoachMark;

  /// Targets for the tutorial
  static List<TargetFocus> targets = [];

  static void loadTutorial(BuildContext context) {
    if (tutorialCoachMark != null) {
      return;
    }

    try {
      isScrolling = false;
      financialTutorial(context, () {
        assetTutorial(context, () {
          continuefinancialTutorial2(context, () {
            debtTutorial(context, () {
              continuefinancialTutorial3(context, () {
                graphTutorial(context, () {
                  gptTutorial(context, () {
                    contentTutorial(context, () {
                      profileTutorial(context, () {
                        isScrolling = false;
                        while (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                        HomePage.setTab(0);
                        if (FinancialPage.financialPageController.hasClients) {
                          FinancialPage.financialPageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.fastOutSlowIn,
                          );
                        }
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    } catch (e) {
      print(e);
    }
  }

  static void financialTutorial(BuildContext context, Function()? onFinish) {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    HomePage.setTab(0);
    if (FinancialPage.financialPageController.hasClients) {
      FinancialPage.financialPageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      );
    }

    targets = [
      TargetFocus(
        identify: "tab1",
        keyTarget: financialKeys[0],
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition:
                CustomTargetContentPosition(top: ResStyle.height * 0.4),
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Welcome to BUild Growth! Let's start managing your finances!"),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "asset card",
        keyTarget: financialKeys[1],
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Here is your Total Assets Section. Your latest assets value will display here"),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "debt card",
        keyTarget: financialKeys[2],
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "The Debts Card displays the debts you need to pay this month. Remember, if the card is black, it's time to pay your bills!"),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "expense card",
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        keyTarget: financialKeys[3],
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Expense Card records your total expense for the current month. It turns red if you exceed your set limit."),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "manage asset",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: financialKeys[4],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Click here when you want to add, edit, delete your assets."),
            ),
          ),
        ],
      ),
    ];

    showTutorial(context, onFinish);
  }

  static void graphTutorial(BuildContext context, Function()? onFinish) async {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    HomePage.setTab(0);

    await FinancialPage.financialPageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );

    targets = [
      TargetFocus(
        identify: "transaction graph",
        keyTarget: financialKeys[8],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Based on your Cash Flow History, you can visualize your spending behavior."),
            ),
          ),
        ],
      ),
    ];

    showTutorial(context, onFinish);
  }

  static void assetTutorial(BuildContext context, Function()? onFinish) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AssetDetailPage()));

     await Future.delayed(Duration(milliseconds: 100));
    if (AssetDetailPage.page_controller.hasClients) {
      AssetDetailPage.page_controller.animateToPage(1,
          duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
    }
      await Future.delayed(Duration(milliseconds: 300));

    targets = [
      TargetFocus(
        identify: "cash",
        keyTarget: assetKeys[0],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "This is Cash, which you can record how much cash you are holding now."),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "bank card",
        keyTarget: assetKeys[1],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Take out your Bank Card. Softly place the card at the back or front of your phone to begin. Easy way to manage your bank card.\nMake sure NFC is enabled on your device"),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "property",
        keyTarget: assetKeys[2],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Property is an asset that can continuously generate income, such as a house, car, or gold. However, if the debt is not fully paid off, and its maintenance expenses exceed the income it generated, it is considered a debt."),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "stock",
        keyTarget: assetKeys[3],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "This is Stock, where you can record the current value of the stocks you own.\nRemember, investing in stocks without proper research is not investing ——— it's gambling."),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Deposit Account",
        keyTarget: assetKeys[4],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Deposit Account means the funds, FD, TD that you have invested"),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "others",
        keyTarget: assetKeys[5],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "You can also save other assets that did not mention previously."),
            ),
          ),
        ],
      ),
    ];

    showTutorial(context, onFinish);
  }

  static void debtTutorial(BuildContext context, Function()? onFinish) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => DebtDetailPage()));
    await Future.delayed(Duration(milliseconds: 200));
    if (DebtDetailPage.page_controller.hasClients) {
      DebtDetailPage.page_controller.animateToPage(1,
          duration: Duration(milliseconds: 50), curve: Curves.fastOutSlowIn);
    }
    await Future.delayed(Duration(milliseconds: 300));

    targets = [
      TargetFocus(
        identify: "expenses",
        keyTarget: debtKeys[0],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "This is Expenses, which you can record your expenses on food, fuel, entertainment, and other daily expenses."),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Loans",
        keyTarget: debtKeys[1],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "This is Loans, which you can record your car loan, home loan, or personal loan that require fixed monthly payments.\nAlways pay on time to avoid penalties and protect your creditworthiness!"),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "recurring bill",
        keyTarget: debtKeys[2],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Recurring Bills refer to the fixed payments you need to make every month, such as phone bills, Wi-Fi plans, house rental fees. Keep track of these to ensure timely payments and avoid service interruptions."),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "dynamic bills",
        keyTarget: debtKeys[3],
        shape: ShapeLightFocus.RRect,
        radius: ResStyle.spacing,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Dynamic Bills refer to the dynamic payments you need to make every month, such as electric bills or water bills."),
            ),
          ),
        ],
      ),
    ];

    showTutorial(context, onFinish);
  }

  static void continuefinancialTutorial2(
      BuildContext context, Function()? onFinish) async {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    HomePage.setTab(0);
    if (FinancialPage.financialPageController.hasClients) {
      FinancialPage.financialPageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      );
    }

    targets = [
      TargetFocus(
        identify: "manage debts",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: financialKeys[5],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "Click here when you want to add, edit, delete your debts."),
            ),
          ),
        ],
      ),
    ];

    showTutorial(context, onFinish);
  }

  static void continuefinancialTutorial3(
      BuildContext context, Function()? onFinish) async {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    HomePage.setTab(0);
    if (FinancialPage.financialPageController.hasClients) {
      FinancialPage.financialPageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      );
    }

    targets = [
      TargetFocus(
        identify: "asset transfer",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: financialKeys[6],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "You can transfer your assets between accounts here."),
            ),
          ),
        ],
      ),
       TargetFocus(
        identify: "transaction history",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: financialKeys[7],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                  "You can view the transaction history here. You may add the proof after the transaction is made."),
            ),
          ),
        ],
      ),
    ];

    showTutorial(context, onFinish);
  }

  static void gptTutorial(BuildContext context, Function()? onFinish) async {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    HomePage.setTab(1);

    targets = [
      TargetFocus(
        identify: "gpt",
        keyTarget: gptKeys[0],
        shape: ShapeLightFocus.Circle,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition:
                CustomTargetContentPosition(top: ResStyle.height * 0.3),
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                "Welcome to xBUG AI Assistant! It will provide you with helpful advice on how to manage your finances wisely. You can tap on any replied message to copy it or star it for future reference. Please note that xBUG AI may use your data to improve its responses. If you prefer not to share your data, you can disable this feature at any time in the profile settings.",
              ),
            ),
          ),
        ],
      ),
    ];

    showTutorial(context, onFinish);
  }

  static void contentTutorial(
      BuildContext context, Function()? onFinish) async {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    HomePage.setTab(2);

    targets = [
      TargetFocus(
        identify: "content",
        keyTarget: contentKeys[0],
        shape: ShapeLightFocus.Circle,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition:
                CustomTargetContentPosition(top: ResStyle.height * 0.4),
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                "Here is Content Section. You can browse more interesting events here.",
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "profile icon",
        keyTarget: profileKeys[0],
        shape: ShapeLightFocus.Circle,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition:
                CustomTargetContentPosition(top: ResStyle.height * 0.4),
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                "Last but not least, let's go to your profile settings!",
              ),
            ),
          ),
        ],
      ),
    ];

    showTutorial(context, onFinish);
  }

  static void profileTutorial(
      BuildContext context, Function()? onFinish) async {
    HomePage.setTab(3);
    isScrolling = true;
     ProfilePage.scrollController.animateTo(
         0,
          duration: Duration(milliseconds: 100),
          curve: Curves.fastOutSlowIn);
    await Future.delayed(Duration(milliseconds: 300));

    targets = [
      TargetFocus(
        identify: "info",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: profileKeys[1],
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard("Here is your profile."),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "info edit",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: profileKeys[2],
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard("You can edit your profile here."),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "usegpt",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: profileKeys[3],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                "This feature is important for enabling xBUG AI to give you financial advice",
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "use third party",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: profileKeys[4],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                "This feature is important for allowing xBUG AI to share your information with third-party services, ensuring faster and higher-quality responses.",
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "content",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: profileKeys[5],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                "This feature allows us to understand your preferences and recommend personalized content and events that suit your interests.",
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "proof",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: profileKeys[6],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                "This feature is essential for reminding you to add proof to the transaction after it is made.",
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "google drive",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: profileKeys[7],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                "This feature is essential for backing up your data to your Google Drive. We prioritize your privacy and do not store your financial data on our servers.",
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "tour guide",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: ResStyle.spacing,
        keyTarget: profileKeys[8],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: GestureDetector(
              onTap: () {
                tutorialCoachMark?.next();
              },
              child: TutorialCard(
                "That's it! Feel free to start the tour again if you'd like.",
              ),
            ),
          ),
        ],
      ),
    ];

    showTutorial(context, onFinish);
  }

  static void nextStep(TargetFocus target) {
    if (isClicking) {
      tutorialCoachMark?.previous();
      return;
    }
    isClicking = true;

    if (ProfilePage.scrollController.hasClients &&
        isScrolling &&
        target.identify != "info") {
      ProfilePage.scrollController.animateTo(
          ProfilePage.scrollController.position.pixels + ResStyle.height * 0.18,
          duration: Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn);
    }
    // Allow the next step after a short delay
    Future.delayed(Duration(milliseconds: 300), () {
      isClicking = false; // Reset flag after delay
      //tutorialCoachMark?.next();
    });
    // if (target.identify == "expense card") {
    //   // Navigate to the second tab
    //   FinancialPage.financialPageController.animateToPage(
    //     1,
    //     duration: const Duration(milliseconds: 200),
    //     curve: Curves.fastOutSlowIn,
    //   );

    //   // Move to the next tutorial target after a short delay
    //   tutorialCoachMark?.next();
    // } else if (target.identify == "transaction graph") {
    //   // Proceed to next tutorial step for graph section
    //   tutorialCoachMark?.next();
    // }
  }

  // /// Initialize the tutorial with new targets
  // static void initTutorial(List<TargetFocus> newTargets,
  //     {VoidCallback? onFinish, VoidCallback? onSkip}) {
  //   targets = newTargets;

  //   tutorialCoachMark = TutorialCoachMark(
  //     targets: targets,
  //     colorShadow: Colors.black,
  //     textSkip: "SKIP",
  //     paddingFocus: 10,
  //     opacityShadow: 0.8,
  //     onFinish: onFinish,
  //     onClickTarget: (target) {
  //       debugPrint("Clicked on ${target.identify}");
  //     },
  //   );
  // }

  /// Show the tutorial
  static void showTutorial(BuildContext context, Function()? onFinish) {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        tutorialCoachMark = null;
        if (onFinish != null) {
          onFinish();
        }
      },
      onSkip: () {
        tutorialCoachMark = null;
        return true;
      },
      // onClickTargetWithTapPosition: (target, p1) {
      //   if (target.identify == "profile icon") {
      //     return;
      //   }
      //   nextStep(target);
      // },
      onClickTarget: (target) async {
        //await Future.delayed(Duration(milliseconds: 300));
        nextStep(target);
      },
      onClickOverlay: (p0) {
        nextStep(p0);
      },
    );

    if (tutorialCoachMark != null) {
      tutorialCoachMark!.show(context: context);
    }
  }
}
