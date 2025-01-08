import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/content/content_bloc.dart';
import 'package:build_growth_mobile/env.dart';
import 'package:build_growth_mobile/pages/content/attendacne_listen_page.dart';
import 'package:build_growth_mobile/pages/content/clicked_content_Page.dart';
import 'package:build_growth_mobile/pages/content/enrolled_content_page.dart';
import 'package:build_growth_mobile/pages/widget_tree/home_page.dart';
import 'package:build_growth_mobile/services/tutorial_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
import 'package:build_growth_mobile/widget/bug_emoji.dart';
import 'package:build_growth_mobile/widget/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentListPage extends StatefulWidget {
  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentListPage> {
  void openWebView(String url, String name) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WebViewWPage(
                url: url,
                header: name,
              )),
    );
    await Future.delayed(Duration(milliseconds: 50));
    BlocProvider.of<ContentBloc>(context).add(ContentRequest());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BugAppBarWithContainer(
        'Contnent For You',
        context,
        containerChild: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BugRoundGradientButton(
              icon: Icons.emoji_events,
              text_color: HIGHTLIGHT_COLOR,
              color: RM20_COLOR,
              label: 'Enrollment',
              onPressed: () async {
                var link = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AttendacneListenPage()));

                if (link != null && link is String) {
                  openWebView(link, 'Content Info');
                }
               // await Future.delayed(Duration(milliseconds: 50));
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
                // if (MediaQuery.of(context).viewInsets.bottom > 0)
                //v {
                //   FocusManager.instance.primaryFocus?.unfocus();
                // }
              },
            ),
            BugRoundGradientButton(
              icon: Icons.history_rounded,
              text_color: HIGHTLIGHT_COLOR,
              color: RM20_COLOR,
              label: 'History',
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EnrolledContentPage()));

                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
            BugRoundGradientButton(
              icon: Icons.visibility_sharp,
              text_color: HIGHTLIGHT_COLOR,
              color: RM20_COLOR,
              label: 'Viewed',
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ClickedContentPage()));
              
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
          ],
        ),
      ), // BugAppBar('Content For You', context, gkey: TutorialHelper.profileKeys[0]),
      backgroundColor: HIGHTLIGHT_COLOR,
      body: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          if (state is ContentReadyState) {
            final resourceList = state.list
                .where(
                    (x) => x.content_category == ContentBloc.microlearning_id)
                .toList();
            final eventList = state.list
                .where(
                    (x) => x.content_category != ContentBloc.microlearning_id)
                .toList();

            final recommendations = state.recommendations;

var d = MediaQuery.of(context).viewInsets.bottom;
            if (HomePage.currentIndex == 2 
                ) {
              FocusManager.instance.primaryFocus?.unfocus();
            }

            BlocProvider.of<ContentBloc>(context).add(ViewContentEvent());

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: ResStyle.spacing,
                right: ResStyle.spacing,
                top: ResStyle.spacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enrollment Button
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     BugRoundButton(
                  //       icon: Icons.emoji_events,
                  //       color: RM20_COLOR,
                  //       label: 'Enrollment',
                  //       onPressed: () async {
                  //        var link =  await Navigator.of(context).push(MaterialPageRoute(
                  //             builder: (context) => AttendacneListenPage()));

                  //         if(link!= null && link is String){
                  //           openWebView(link, 'Content Info');
                  //         }
                  //         FocusScope.of(context).unfocus();
                  //       },
                  //     ),
                  //     BugRoundButton(
                  //       icon: Icons.history_rounded,
                  //       color: RM20_COLOR,
                  //       label: 'History',
                  //       onPressed: () async {
                  //         await Navigator.of(context).push(MaterialPageRoute(
                  //             builder: (context) => EnrolledContentPage()));

                  //         FocusScope.of(context).unfocus();
                  //       },
                  //     ),
                  //     BugRoundButton(
                  //       icon: Icons.visibility_sharp,
                  //       color: RM20_COLOR,
                  //       label: 'Viewed',
                  //       onPressed: () async {
                  //         await Navigator.of(context).push(MaterialPageRoute(
                  //             builder: (context) => ClickedContentPage()));
                  //         FocusScope.of(context).unfocus();
                  //       },
                  //     ),
                  //   ],
                  // ),
                  BugEmoji(
                    message:
                        "Here are some recommendations we think you'll enjoy: ${recommendations.join(', ')}",
                  ),
                  // Text(
                  //   "Here are some recommendations we think you'll enjoy: ${recommendations.join(', ')}",
                  //   style: TextStyle(
                  //     fontSize: ResStyle.small_font,
                  //     fontWeight: FontWeight.normal,
                  //     color: TITLE_COLOR,
                  //     //height: 1.5,
                  //   ),
                  //   textAlign: TextAlign.justify,
                  //   softWrap: true,
                  //   overflow: TextOverflow.visible,
                  // ),
                  SizedBox(
                    height: ResStyle.spacing,
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Micro Learning',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResStyle.body_font,
                            color: TITLE_COLOR,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Resources Section

                  SizedBox(height: ResStyle.spacing),
                  ...resourceList
                      .map((content) => buildContentCard(content, () {
                            BlocProvider.of<ContentBloc>(context)
                                .add(ClickContentEvent(id: content.id));
                            openWebView(content.link, 'Content Detail');
                          })),
                  SizedBox(height: ResStyle.spacing),
                  Divider(),

                  // Events Section
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Upcoming Event',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResStyle.body_font,
                            color: TITLE_COLOR,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResStyle.spacing),
                  ...eventList.map((content) => buildContentCard(content, () {
                        BlocProvider.of<ContentBloc>(context)
                            .add(ClickContentEvent(id: content.id));
                        openWebView(content.link, 'Content Detail');
                      })),

                  SizedBox(height: ResStyle.spacing * 2),

                  Row(
                    children: [
                      Expanded(
                        child: BugIconGradientButton(
                          text: 'Browse More',
                          icon: Icons.switch_access_shortcut_add_outlined,
                          fontSize: ResStyle.font,
                          onPressed: () {
                            openWebView(CONTENT_URL, 'Content');
                          },
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: ResStyle.spacing),
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
