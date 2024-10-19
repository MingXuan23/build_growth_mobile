import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  Widget page =Container(); //empty page
  @override
  Widget build(BuildContext context) {
      return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if(state is LoginInitial){
          page = LoginPage();
        }
      },
      child: page,
    );
  }
}