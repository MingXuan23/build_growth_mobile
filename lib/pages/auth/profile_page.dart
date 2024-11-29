import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/main.dart';
import 'package:build_growth_mobile/models/user_info.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/pages/widget_tree/start_page.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_input.dart';
import 'package:build_growth_mobile/widget/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool useGPT = UserPrivacy.useGPT;
  bool pushContent = UserPrivacy.pushContent;
  String backupFrequency = UserPrivacy.backUpFrequency;
  UserInfo user = UserInfo(
      name: "xxx",
      email: "xxx@xxx.xx",
      address: "xxx",
      telno: "xxx",
      state: "xxx");

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> updateUserPrivacy() async {
    setState(() {
      UserPrivacy.useGPT = useGPT;
      UserPrivacy.pushContent = pushContent;
      UserPrivacy.backUpFrequency = backupFrequency;
    });
    await UserPrivacy.saveToPreferences(UserToken.user_code!);
  }

  Future<void> logOut() async {
    Navigator.of(context).pop();
    BlocProvider.of<AuthBloc>(context).add(LogoutRequested());
  }


  void showChangePasswordDialog() {
   
    
    final _formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Form(
          key: _formKey,
          child: BugBottomModal(
            header: "Change Password",
            widgets: [
              BugTextInput(
                controller: oldPasswordController,
                label: 'Old Password',
                hint: 'Enter Old Password',
                prefixIcon: Icon(Icons.password),
                obscureText: true,
              ),
              SizedBox(
                height: ResStyle.spacing * 2,
              ),
              BugTextInput(
                controller: newPasswordController,
                label: 'New Password',
                hint: 'Enter New Password',
                prefixIcon: Icon(Icons.edit),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
                  bool hasLowercase = value.contains(RegExp(r'[a-z]'));
                  bool hasDigits = value.contains(RegExp(r'\d'));
                  bool hasSpecialCharacters =
                      value.contains(RegExp(r'[@$!%*?&#^_=+-]'));
                  bool hasMinLength = value.length >= 8;

                  List<String> errors = [];
                  if (value == oldPasswordController.text) {
                    return 'New password cannot same as old password.';
                  }
                  if (!hasUppercase) {
                    errors.add('At least one uppercase letter');
                  }
                  if (!hasLowercase) {
                    errors.add('At least one lowercase letter');
                  }
                  if (!hasDigits) {
                    errors.add('At least one number');
                  }
                  if (!hasSpecialCharacters) {
                    errors.add('At least one special character');
                  }
                  if (!hasMinLength) {
                    errors.add('At least 8 characters long');
                  }

                  if (errors.isNotEmpty) {
                    return errors
                        .join('\n'); // Join all error messages with new lines
                  }

                  return null; // Return null if there are no errors
                },
              ),
              SizedBox(
                height: ResStyle.spacing,
              ),
              BugTextInput(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Enter Confirm Password',
                prefixIcon: Icon(Icons.edit),
                obscureText: true,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: ResStyle.spacing,
              ),
              BugPrimaryButton(
                  color: TITLE_COLOR,
                  text: 'Save',
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    BlocProvider.of<AuthBloc>(context).add(
                        ChangePasswordRequest(
                            oldPassword: oldPasswordController.text,
                            newPassword: newPasswordController.text));
                    Navigator.of(context).pop();
                  }),
              SizedBox(
                height: ResStyle.spacing,
              ),
              BugPrimaryButton(
                  text: 'Cancel',
                  color: DANGER_COLOR,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
            context: context,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthChangePasswordResult) {
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(BugSnackBar(state.message, 5));
          showTopSnackBar(context, state.message,5);
          if (state.success) {
            logOut();
          }
        }
      },
      child: Scaffold(
        appBar: BugAppBar('Your Profile', context, show_icon: false),
        backgroundColor: HIGHTLIGHT_COLOR,
        body: Padding(
          padding: EdgeInsets.all(ResStyle.spacing),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Information Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: HIGHTLIGHT_COLOR.withOpacity(0.85),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(ResStyle.spacing),
                        child: Text(
                          'Profile Information',
                          style: TextStyle(
                              fontSize: ResStyle.body_font,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),
                      CardInfoDivider("Name", user.name),
                      CardInfoDivider("Email", user.email),
                      CardInfoDivider("Tel Num", user.telno),
                      CardInfoDivider("State", user.state),
                      CardInfoDivider("Address", user.address, isLast: true),
                    ],
                  ),
                ),

                SizedBox(height: ResStyle.spacing), // Spacing between cards

                // Privacy Settings Card
                Card(
                  color: HIGHTLIGHT_COLOR.withOpacity(0.85),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(ResStyle.spacing),
                        child: Text(
                          'Privacy Settings',
                          style: TextStyle(
                              fontSize: ResStyle.body_font,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),
                      CardWidgetivider(
                        'Allow AI Financial Assitant using your data',
                        BugSwitch(
                          value: useGPT,
                          onChanged: (value) {
                            setState(() {
                              useGPT = value;
                            });
                            updateUserPrivacy();
                          },
                        ),
                      ),
                      CardWidgetivider(
                          'Allow receiving recommendations',
                          BugSwitch(
                            value: pushContent,
                            onChanged: (value) {
                              setState(() {
                                pushContent = value;
                              });
                              updateUserPrivacy();
                            },
                          )),
                      CardWidgetivider(
                        'Backup',
                        DropdownButton<String>(
                          dropdownColor: HIGHTLIGHT_COLOR,
                          value: backupFrequency,
                          items: [
                            "No Backup",
                            "First Transaction In A Day",
                            "First Transaction In A Month",
                            "Every Transaction",
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                backupFrequency = newValue;
                              });
                              updateUserPrivacy();
                            }
                          },
                        ),
                      ),
                      CardWidgetivider(
                          'Last updated at: ${DateTime.now().toString().substring(0, 16)}',
                          BugIconButton(
                              text: 'Backup now',
                              onPressed: () {
                                //backupMyDataNow(); // Define this function to handle the backup process
                              },
                              icon: Icons.backup)),
                      CardWidgetivider(
                          'Last Backup at:  ${DateTime.now().subtract(Duration(days: 1)).toString().substring(0, 16)}',
                          BugIconButton(
                              text: 'Restore now',
                              onPressed: () {
                                //backupMyDataNow(); // Define this function to handle the backup process
                              },
                              icon: Icons.restore),
                          isLast: true),
                      SizedBox(
                        height: ResStyle.spacing / 2,
                      )
                    ],
                  ),
                ),
                SizedBox(height: ResStyle.spacing),
                // Action Buttons
                Padding(
                  padding: EdgeInsets.symmetric(vertical: ResStyle.spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BugPrimaryButton(
                          text: "Change Password",
                          onPressed: showChangePasswordDialog,
                          color: TITLE_COLOR),
                      SizedBox(height: ResStyle.spacing),
                      BugPrimaryButton(
                          text: "Log Out",
                          onPressed: logOut,
                          color: DANGER_COLOR),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
