import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/content/content_bloc.dart';
import 'package:build_growth_mobile/env.dart';
import 'package:build_growth_mobile/pages/content/attendacne_listen_page.dart';
import 'package:build_growth_mobile/pages/content/clicked_content_Page.dart';
import 'package:build_growth_mobile/pages/content/enrolled_content_page.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
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

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BugAppBar('Content For You', context),
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

            BlocProvider.of<ContentBloc>(context).add(ViewContentEvent());

            return SingleChildScrollView(
              padding: EdgeInsets.all(ResStyle.spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enrollment Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BugRoundButton(
                        icon: Icons.emoji_events,
                        color: RM20_COLOR,
                        label: 'Enrollment',
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AttendacneListenPage()));
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      BugRoundButton(
                        icon: Icons.history_rounded,
                        color: RM20_COLOR,
                        label: 'History',
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EnrolledContentPage()));
                         
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      BugRoundButton(
                        icon: Icons.visibility_sharp,
                        color: RM20_COLOR,
                        label: 'Viewed',
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ClickedContentPage()));
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: ResStyle.spacing),

                  // Browse More Button

                  Divider(),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Resource',
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
                  BugPrimaryButton(
                    text: 'Browse More',
                    borderRadius: 8,
                    onPressed: () {
                      openWebView(CONTENT_URL, 'Content');
                    },
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
