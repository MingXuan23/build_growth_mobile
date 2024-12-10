import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/content/content_bloc.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContentListPage extends StatefulWidget {
  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentListPage> {
  String option = '1';
  bool isMicroLearning = true;

  void updateCategory(String option) {
    setState(() {
      isMicroLearning = option == '1';
      this.option = option;
    });
  }

  void openWebView(String url, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewWPage(url: url, header: name,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final contentList = isMicroLearning ? microLearningContent : eventContent;

    return Scaffold(
      appBar: BugAppBar('Content For You', context),
      backgroundColor: HIGHTLIGHT_COLOR,
      body: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          if (state is ContentReadyState) {
            return Padding(
              padding: EdgeInsets.all(ResStyle.spacing),
              child: Column(
                children: [
                  // Top Option Bar
                  Container(
                    decoration: BoxDecoration(
                      color: HIGHTLIGHT_COLOR,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PRIMARY_COLOR),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          onTap: () => updateCategory('1'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: ResStyle.spacing),
                            decoration: BoxDecoration(
                              color: option == '1'
                                  ? TITLE_COLOR
                                  : HIGHTLIGHT_COLOR,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Resource',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: ResStyle.font,
                                color: isMicroLearning
                                    ? HIGHTLIGHT_COLOR
                                    : TITLE_COLOR,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => updateCategory('2'),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: ResStyle.spacing),
                              decoration: BoxDecoration(
                                color: option != '1'
                                    ? TITLE_COLOR
                                  : HIGHTLIGHT_COLOR,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Event',
                               textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: ResStyle.font,
                                color: !isMicroLearning
                                    ? HIGHTLIGHT_COLOR
                                    : TITLE_COLOR,
                                fontWeight: FontWeight.w500,
                              ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          SizedBox(height: ResStyle.spacing,),
                  // List View of Content Cards
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.list
                          .where((x) =>
                              isMicroLearning == (x.content_category == '1'))
                          .length,
                      itemBuilder: (context, index) {
                        final content = state.list
                            .where((x) =>
                                isMicroLearning == (x.content_category == '1'))
                            .toList()[index];
                        return Padding(
                          padding:  EdgeInsets.symmetric(vertical: ResStyle.spacing/2),
                          child: Card(
                            
                          color: RM20_COLOR.withOpacity(0.8),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: ResStyle.height * 0.15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:  EdgeInsets.all(ResStyle.spacing),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                content.name,
                                                style: TextStyle(
                                                  fontSize: ResStyle.font,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: ResStyle.spacing),
                                              Text(content.desc, style: TextStyle(fontSize: ResStyle.small_font),),
                                              SizedBox(height: ResStyle.spacing/2,),
                                              //BugRoundButton(icon: Icons.chevron_right_rounded, onPressed: (){}),
                                              
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                   BugRoundButton(icon: Icons.chevron_right_rounded, onPressed: ()=>   openWebView(content.link, 'Content Detail'),),
                                   SizedBox(width: ResStyle.spacing,)
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text('Error occur'),
            );
          }
        },
      ),
    );
  }
}
