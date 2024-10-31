import 'package:build_growth_mobile/assets/color_sample.dart';
import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/pages/auth/login_page.dart';
import 'package:build_growth_mobile/pages/financial/financial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  Widget page = LoginPage(); //empty page

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is LoginInitial) {
          page = LoginPage();
        } else if (state is LoginSuccess) {
          page = FinancialPage();
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
