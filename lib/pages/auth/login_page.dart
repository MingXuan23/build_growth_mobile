import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PRIMARY_COLOR,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Container(
                  color: PRIMARY_COLOR,
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
                          padding: EdgeInsets.all(2*ResStyle.spacing),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: ResStyle.spacing),
                                Text('Logo here'),
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
                                SizedBox(height: 2* ResStyle.spacing),
                                BugPrimaryButton(
                                    text: 'Log In', onPressed: _submitForm),
                                SizedBox(height: ResStyle.spacing),
                                BugPrimaryButton(
                                    text: 'Register', onPressed: _submitForm),

                                BugTextButton(
                                  onPressed: _submitForm,
                                  text: "Forgot Password?",
                                ),
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
