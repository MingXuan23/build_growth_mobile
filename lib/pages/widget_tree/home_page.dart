
import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/pages/content/content_page.dart';
import 'package:build_growth_mobile/pages/financial/financial_page.dart';
import 'package:build_growth_mobile/pages/financial/transaction_history_page.dart';
import 'package:build_growth_mobile/pages/gpt/gpt_page.dart';
import 'package:build_growth_mobile/pages/gpt/message_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});



  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Widget> tabs = [FinancialPage(), MessagePage(),ContentPage()];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
       
        body: IndexedStack(children: tabs , index: currentIndex,),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
           currentIndex =index;
            FocusScope.of(context).unfocus();

          setState(() {
            
          });
        
        },
      items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.monetization_on_rounded,
              color: currentIndex == 0 ? TITLE_COLOR : HIGHTLIGHT_COLOR, // Customize icon color based on selection
              size: ResStyle.header_font, // Custom icon size
            ),
            label: 'Financial',
            backgroundColor: RM1_COLOR
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt,
              color: currentIndex == 1 ? TITLE_COLOR : HIGHTLIGHT_COLOR,
              size: ResStyle.header_font,
            ),
            label: 'Assistant',
            backgroundColor: RM50_COLOR
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.article,
              color: currentIndex == 2 ? TITLE_COLOR: HIGHTLIGHT_COLOR,
              size: ResStyle.header_font,
            ),
            label: 'Content',
            backgroundColor: PRIMARY_COLOR
          ),
        ],
        selectedItemColor: TITLE_COLOR, // Selected item color
        unselectedItemColor: HIGHTLIGHT_COLOR, // Unselected item color
        selectedFontSize: ResStyle.font, // Font size for selected label
        unselectedFontSize: ResStyle.medium_font, // Font size for unselected label
        
        type: BottomNavigationBarType.shifting, // Ensures all items are aligned properly
         showSelectedLabels: true, // Ensures selected labels are visible
          showUnselectedLabels: true, // Ensures unselected labels are visible
          
      
      ),
      ),
    );
  }
}
