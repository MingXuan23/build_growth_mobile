import 'package:build_growth_mobile/assets/color_sample.dart';
import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/pages/auth/login_page.dart';
import 'package:build_growth_mobile/pages/financial/financial_page.dart';
import 'package:build_growth_mobile/pages/financial/nfc_card_example.dart';
import 'package:build_growth_mobile/pages/widget_tree/home_page.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  Widget page = Scaffold(
    backgroundColor: HIGHTLIGHT_COLOR,
    body: BugLoading(),
  ); //empty page

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthBloc>(context).add(
      AutoLoginRequest(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is LoginInitial) {
          page = LoginPage();
        } else if (state is LoginSuccess) {
          page = HomePage();
        } else if (state is RegisterSuccess) {
          page = LoginPage();
        }

        setState(() {});
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          ResStyle.initialise(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height);

          return page;
        },
      ),
    );
  }
}
