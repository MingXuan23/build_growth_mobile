import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/env.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/pages/auth/register_page.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.email});

  final String? email;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with login
      BlocProvider.of<AuthBloc>(context).add(
        LoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  void pushRegisterPage() {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => RegisterPage()));
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email ??  UserToken.email??'';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Container(
                  color: RM50_COLOR,
                  child: Padding(
                    padding: EdgeInsets.all(ResStyle.spacing),
                    child: Center(
                      child: Card(
                        color: HIGHTLIGHT_COLOR,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2 * ResStyle.spacing),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: ResStyle.spacing),
                                Container(
                                 
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12)) ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                     Image.asset(
                                  'lib/assets/playstore-icon.png',
                                  height: ResStyle.spacing * 5,
                                  width: ResStyle.spacing * 5,
                                ),
                                SizedBox(width: ResStyle.spacing,),
                                Text('BUild Growth',style: TextStyle(color: LOGO_COLOR, fontSize: ResStyle.body_font, fontWeight: FontWeight.w900),),
                                  ],),
                                ),
                               
                                SizedBox(height: ResStyle.spacing),
                                BugTextInput(
                                  controller: _emailController,
                                  prefixIcon: Icon(Icons.email_rounded),
                                  label: 'Email',
                                  hint: "Enter Your Email",
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: ResStyle.spacing),
                                BugTextInput(
                                    controller: _passwordController,
                                    label: "Password",
                                    hint: "Enter your password",
                                    obscureText: true,
                                    prefixIcon: Icon(Icons.lock)),
                                SizedBox(height: 2 * ResStyle.spacing),
                                BugPrimaryButton(
                                    text: 'Log In', onPressed: _submitForm),
                                SizedBox(height: ResStyle.spacing),
                                BugPrimaryButton(
                                    text: 'Register',
                                    onPressed: pushRegisterPage,
                                    color: TITLE_COLOR),
                                BugTextButton(
                                    onPressed: () {
                                      final emailRegex = RegExp(
                                          r'^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$');
                                      var value = _emailController.text;
                                      if (value == null || value.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(BugSnackBar(
                                                'Email is required', 5));
                                        return;
                                      } else if (!emailRegex.hasMatch(value)) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(BugSnackBar(
                                                'Enter a valid email', 5));
                                        return;
                                      }

                                      BlocProvider.of<AuthBloc>(context).add(
                                          AuthForgetPassword(
                                              email: _emailController.text));
                                    },
                                    text: "Forgot Password?",
                                    underline: true),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
