import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/content/content_bloc.dart';
import 'package:build_growth_mobile/bloc/content_init/content_init_bloc.dart';
import 'package:build_growth_mobile/models/content.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/pages/content/content_init_page.dart';
import 'package:build_growth_mobile/pages/content/content_list_page.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //showMessage();
    BlocProvider.of<ContentBloc>(context).add(ContentRequest());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentBloc, ContentState>(
      listener: (context, state) {
        if (state is ContentTestResultState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(BugSnackBar(state.message, 5));
          BlocProvider.of<ContentBloc>(context).add(ContentRequest());
        }
      },
      child: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          if (!UserPrivacy.pushContent) {
            return Scaffold(
              appBar: BugAppBar('Content', context),
              backgroundColor: HIGHTLIGHT_COLOR,
              body: Center(
                  child: Padding(
                padding: EdgeInsets.all(ResStyle.spacing),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBugEmoji(
                        message:
                            "Aww, looks like you turned off the content recommendation service! 🐞✨ Don't worry, you can switch it back on anytime from your profile settings! 🌟💖"),
                    SizedBox(
                      height: ResStyle.spacing,
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric( horizontal:  ResStyle.spacing),
                      child: BugPrimaryButton(
                          color: TITLE_COLOR,
                          text: "Enable Content Browsing",
                          onPressed: () {
                            redirectToProfile(context,true);
                          }),
                    )
                  ],
                ),
              )),
            );
          } else if (!UserToken.online) {
            return Scaffold(
              appBar: BugAppBar('Content', context),
              backgroundColor: HIGHTLIGHT_COLOR,
              body: Center(
                  child: Padding(
                padding: EdgeInsets.all(ResStyle.spacing),
                child: AnimatedBugEmoji(
                    message:
                        "Oopsie! 😅 Looks like the connection flew away! 😿 Don't worry, I'm buzzing to fix it! 🐝 Could you restart the app to help me out? 💕?"),
              )),
            );
          } else if (state is ContentTestState) {
            BlocProvider.of<ContentInitBloc>(context)
                .add(ResetContentEvent(contentList: state.list));

            return ContentInitPage();
          } else if (state is ContentTestResultState || state is ContentLoadingState) {
            return BugLoading();
          } else if (state is ContentReadyState) {
            return ContentListPage();
          }
          return BugLoading();
         // return ContentInitPage();
        },
      ),
    );
  }
}

