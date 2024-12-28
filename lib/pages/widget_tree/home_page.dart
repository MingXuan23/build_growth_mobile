import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';
import 'package:build_growth_mobile/models/user_backup.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/pages/auth/backup_page.dart';
import 'package:build_growth_mobile/pages/content/attendacne_listen_page.dart';
import 'package:build_growth_mobile/pages/content/content_page.dart';
import 'package:build_growth_mobile/pages/financial/financial_page.dart';
import 'package:build_growth_mobile/pages/financial/transaction_history_page.dart';
import 'package:build_growth_mobile/pages/gpt/gpt_page.dart';
import 'package:build_growth_mobile/pages/gpt/message_page.dart';
import 'package:build_growth_mobile/services/backup_helper.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/services/tutorial_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
 static final GlobalKey<_HomePageState> homePageKey = GlobalKey<_HomePageState>();
  @override
  State<HomePage> createState() => _HomePageState();

   static void setTab(int index) {
    homePageKey.currentState?._setTab(index);
  }
}

class _HomePageState extends State<HomePage> {

   void _setTab(int index) {
    if (index != currentIndex) {
      setState(() {
        currentIndex = index;
      });
    }
  }

  Future<bool?> _showBackDialog() {
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

  List<Widget> tabs = [FinancialPage(), MessagePage(), ContentPage()];
  //List<Widget> tabs = [FinancialPage(), MessagePage(),   DriveBackupWidget()];
int currentIndex = 0;
   
  @override
  void initState() {
    super.initState();
    if (UserPrivacy.googleDriveBackup) {
      GoogleDriveBackupHelper.initialize();

      if (!FormatterHelper.isToday(UserBackup.lastBackUpTime)) {
        BlocProvider.of<AuthBloc>(context).add(UserStartBackup());
      }
    }

    BlocProvider.of<MessageBloc>(context).add(
      SendMessageEvent('Initialising xBUG Ai...'),
    );

    if(AuthBloc.first_user){
       BlocProvider.of<AuthBloc>(context).add(UserTourGuide());
       AuthBloc.first_user = false;
    }
    _startNFCReading();
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

            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AttendacneListenPage()));
            
          },
        );
      } 
    } catch (e) {
      debugPrint('Error reading NFC: $e');
    }
  }

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
            index: currentIndex,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              currentIndex = index;
              FocusScope.of(context).unfocus();

              setState(() {});
            },
            items: [
              BottomNavigationBarItem(
                key: TutorialHelper.financialKeys[0],
                  icon: Icon(
                    Icons.monetization_on_rounded,
                    color: currentIndex == 0
                        ? TITLE_COLOR
                        : HIGHTLIGHT_COLOR, // Customize icon color based on selection
                    size: ResStyle.header_font, // Custom icon size
                  ),
                  label: 'Financial',
                  backgroundColor: RM1_COLOR),
              BottomNavigationBarItem(
                key: TutorialHelper.gptKeys[0],
                  icon: Icon(
                    Icons.receipt,
                    color: currentIndex == 1 ? TITLE_COLOR : HIGHTLIGHT_COLOR,
                    size: ResStyle.header_font,
                  ),
                  label: 'Assistant',
                  backgroundColor: RM50_COLOR),
              BottomNavigationBarItem(
                key: TutorialHelper.contentKeys[0],
                  icon: Icon(
                    Icons.article,
                    color: currentIndex == 2 ? TITLE_COLOR : HIGHTLIGHT_COLOR,
                    size: ResStyle.header_font,
                  ),
                  label: 'Content',
                  backgroundColor: PRIMARY_COLOR),
            ],
            selectedItemColor: TITLE_COLOR, // Selected item color
            unselectedItemColor: HIGHTLIGHT_COLOR, // Unselected item color
            selectedFontSize: ResStyle.font, // Font size for selected label
            unselectedFontSize:
                ResStyle.medium_font, // Font size for unselected label

            type: BottomNavigationBarType
                .shifting, // Ensures all items are aligned properly
            showSelectedLabels: true, // Ensures selected labels are visible
            showUnselectedLabels: true, // Ensures unselected labels are visible
          ),
        ),
      ),
    );
  }
}
