import 'package:build_growth_mobile/assets/color_sample.dart';
import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
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
  void dispose() {
    // Dispose of any resources here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(BugSnackBar(state.error, 5));
        } else if (state is LoginInitial) {
          if (state.message?.isNotEmpty ?? false) {
            ScaffoldMessenger.of(context)
                .showSnackBar(BugSnackBar(state.message ?? '', 5));
          }
        } else if (state is AuthForgetPasswordResult) {
          ScaffoldMessenger.of(context)
              .showSnackBar(BugSnackBar(state.message, 5));
        }

        setState(() {});
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              ResStyle.initialise(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height);

              if (state is LoginInitial) {
                return LoginPage(
                  email: state.email,
                );
              } else if (state is LoginSuccess || state is AuthChangePasswordResult || state is AuthUpdateProfileResult) {
                 
                return HomePage();
              } else if (state is RegisterSuccess) {
                return LoginPage();
              } else if (state is AuthLoading) {
                return Scaffold(
                  body: BugLoading(),
                );
              }

              return LoginPage();
            },
          );
        },
      ),
    );
  }
}
