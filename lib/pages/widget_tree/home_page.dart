import 'dart:convert';

import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/bloc/content/content_bloc.dart';
import 'package:build_growth_mobile/bloc/gold_leaf_bloc/gold_leaf_bloc.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';
import 'package:build_growth_mobile/models/user_backup.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/pages/auth/backup_page.dart';
import 'package:build_growth_mobile/pages/auth/profile_page.dart';
import 'package:build_growth_mobile/pages/content/attendacne_listen_page.dart';
import 'package:build_growth_mobile/pages/content/content_page.dart';
import 'package:build_growth_mobile/pages/financial/financial_page.dart';
import 'package:build_growth_mobile/pages/financial/transaction_history_page.dart';
import 'package:build_growth_mobile/pages/gpt/gpt_page.dart';
import 'package:build_growth_mobile/pages/gpt/message_page.dart';
import 'package:build_growth_mobile/services/backup_helper.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/services/tutorial_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static int currentIndex = 0;
  static final GlobalKey<_HomePageState> homePageKey =
      GlobalKey<_HomePageState>();


  @override
  State<HomePage> createState() => _HomePageState();

  static void setTab(int index) {
    homePageKey.currentState?._setTab(index);
  }
}

class _HomePageState extends State<HomePage> {
  void _setTab(int index) {
    if (index != HomePage.currentIndex) {
      setState(() {
        HomePage.currentIndex = index;
      });
    }
  }

  Future<bool?> _showBackDialog() async {
     if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.inactive) {
    return false;
  }
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Are you sure you want to leave this page?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Nevermind'),
              onPressed: () {
                Navigator.pop(context, false);
                FocusScope.of(context).unfocus();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Leave'),
              onPressed: () {
                SystemNavigator.pop();
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> tabs = [
    FinancialPage(),
    MessagePage(),
    ContentPage(),
    ProfilePage(gotoPrivacy: false,useGKey: true, useStaticController: true,)
  ];
  //List<Widget> tabs = [FinancialPage(), MessagePage(),   DriveBackupWidget()];
 

  @override
  void initState() {
    super.initState();
    handleGoogleDriveBackup();
    _startNFCReading();
    if (AuthBloc.first_user) {
      BlocProvider.of<AuthBloc>(context).add(UserTourGuide());
      AuthBloc.first_user = false;
    }
    BlocProvider.of<GoldLeafBloc>(context).add(LoadGoldLeafEvent());
  }

  void handleGoogleDriveBackup() async {
    try {
      await UserPrivacy.loadFromPreferences(UserToken.user_code ?? '');
      if (UserPrivacy.googleDriveBackup) {
        bool status = await GoogleDriveBackupHelper.initialize();
        if (!status) {
          throw Exception();
        }

        if (!FormatterHelper.isToday(UserBackup.lastBackUpTime)) {
          BlocProvider.of<AuthBloc>(context).add(UserStartBackup());
        }
      }
    } catch (e) {
      UserPrivacy.googleDriveBackup = false;
      UserPrivacy.saveToPreferences(UserToken.user_code!);
      await AuthRepo.updateUserPrivacy(jsonEncode(UserPrivacy.toMap()));
      ScaffoldMessenger.of(context).showSnackBar(BugSnackBar(
          'Error during google drive backup. Please try again in the profile setting.',
          5));
    }

    BlocProvider.of<MessageBloc>(context).add(
      SendMessageEvent('Initialising xBUG Ai... '),
    );
  }

  void _startNFCReading() async {
    try {
      var nfc_available = await NfcManager.instance.isAvailable();

      //We first check if NFC is available on the device.
      if (nfc_available) {
        //If NFC is available, start an NFC session and listen for NFC tags to be discovered.
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // Process NFC tag, When an NFC tag is discovered, print its data to the console.
            var ndef = Ndef.from(tag);
            if (ndef == null || ndef.cachedMessage == null) {
              return;
            }

            if (ContentBloc.content_list.isEmpty || !UserPrivacy.pushContent) {
              showTopSnackBar(
                  context,
                  'Error when initialise the content. Please check at the content page.',
                  5);
              return;
            }
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AttendacneListenPage()));
          },
        );
      }
    } catch (e) {
      debugPrint('Error reading NFC: $e');
    }
  }

  Color backgroundColor = LOGO_COLOR;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool pop) async {
        // Show the confirmation dialog when user presses the back button
        final bool shouldPop = await _showBackDialog() ?? false;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: IndexedStack(
            children: tabs,
            index: HomePage.currentIndex,
          ),
          bottomNavigationBar: Container(
            height: ResStyle.height * 0.1,
            color: backgroundColor,
            child: BottomNavigationBar(
              backgroundColor: backgroundColor,
              currentIndex: HomePage.currentIndex,
              onTap: (index) {
                HomePage.currentIndex = index;

                // if(index == 0){
                //   backgroundColor = RM1_COLOR;
                // }else if(index == 1){
                //   backgroundColor = RM50_COLOR;
                // }else if (index ==2 ){
                //   backgroundColor = PRIMARY_COLOR;
                // }else {
                //   backgroundColor = RM1_COLOR;
                // }
                FocusScope.of(context).unfocus();

                setState(() {});
              },
              items: [
                BottomNavigationBarItem(
                    key: TutorialHelper.financialKeys[0],
                    icon: Icon(
                      Icons.monetization_on_rounded,

                       color: HomePage.currentIndex == 0
                          ? RM1_COLOR
                          : HIGHTLIGHT_COLOR , // Customize icon color based on selection
                      size: ResStyle.body_font, // Custom icon size
                    ),
                    label: 'Financial',
                    backgroundColor: RM1_COLOR),
                BottomNavigationBarItem(
                    key: TutorialHelper.gptKeys[0],
                    icon: Icon(
                      Icons.chat_rounded,
                       color: HomePage.currentIndex == 1
                          ? RM1_COLOR
                          : HIGHTLIGHT_COLOR , 
                      size: ResStyle.body_font,
                    ),
                    label: 'Assistant',
                    backgroundColor: RM50_COLOR),
                BottomNavigationBarItem(
                    key: TutorialHelper.contentKeys[0],
                    icon: Icon(
                      Icons.article,
                     color: HomePage.currentIndex == 2
                          ? RM1_COLOR
                          : HIGHTLIGHT_COLOR , 
                      size: ResStyle.body_font,
                    ),
                    label: 'Content',
                    backgroundColor: PRIMARY_COLOR),
                BottomNavigationBarItem(
                     key: TutorialHelper.profileKeys[0],
                    icon: Icon(
                      Icons.account_circle,
                     color: HomePage.currentIndex == 3
                          ? RM1_COLOR
                          : HIGHTLIGHT_COLOR , // Customize icon color based on selection
                      size: ResStyle.body_font, // Custom icon size
                    ),
                    label: 'Profile',
                    backgroundColor: LOGO_COLOR),
              ],
              selectedItemColor: HIGHTLIGHT_COLOR, // Selected item color
              unselectedItemColor: HIGHTLIGHT_COLOR, // Unselected item color
              selectedFontSize: ResStyle.font, // Font size for selected label
              unselectedFontSize:
                  ResStyle.small_font, // Font size for unselected label

              type: BottomNavigationBarType
                  .fixed, // Ensures all items are aligned properly
              showSelectedLabels: true, // Ensures selected labels are visible
              showUnselectedLabels:
                  true, // Ensures unselected labels are visible
            ),
          ),
        ),
      ),
    );
  }
}
