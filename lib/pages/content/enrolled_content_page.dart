import 'dart:convert';

import 'package:build_growth_mobile/api_services/content_repo.dart';
import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/attendance/attendance_bloc.dart';
import 'package:build_growth_mobile/bloc/content/content_bloc.dart';
import 'package:build_growth_mobile/models/content.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
import 'package:build_growth_mobile/widget/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class EnrolledContentPage extends StatefulWidget {
  const EnrolledContentPage({super.key});

  @override
  State<EnrolledContentPage> createState() => _EnrolledContentPageState();
}

class _EnrolledContentPageState extends State<EnrolledContentPage> {
  List<Content> list = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loaddata();
  }

  void loaddata() async {
    list = await ContentRepo.getAttendanceHistory();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    void openWebView(String url, String name) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewWPage(
                  url: url,
                  header: name,
                )),
      );
    }

    return Scaffold(
        appBar: BugAppBar('Enrollment History', context),
        body: (list.isEmpty)
            ? Center(
                child: Text('No Enrollment History'),
              )
            : Padding(
                padding: EdgeInsets.all(ResStyle.spacing),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...list.map((content) => buildContentCard(content, () {
                            BlocProvider.of<ContentBloc>(context)
                                .add(ClickContentEvent(id: content.id));
                            openWebView(content.link, 'Content Detail');
                          })),
                    ],
                  ),
                ),
              ));
  }
}
