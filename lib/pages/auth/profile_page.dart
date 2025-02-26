import 'dart:convert';

import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/bloc/content/content_bloc.dart';
import 'package:build_growth_mobile/bloc/financial/financial_bloc.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';

import 'package:build_growth_mobile/main.dart';
import 'package:build_growth_mobile/models/user_backup.dart';
import 'package:build_growth_mobile/models/user_info.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/pages/auth/backup_page.dart';
import 'package:build_growth_mobile/pages/widget_tree/start_page.dart';
import 'package:build_growth_mobile/services/backup_helper.dart';
import 'package:build_growth_mobile/services/location_helper.dart';
import 'package:build_growth_mobile/services/tutorial_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_input.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
      {Key? key,
      required this.gotoPrivacy,
      this.useGKey = false,
      this.useStaticController = false})
      : super(key: key);
  final bool gotoPrivacy;
  final bool useGKey;
  final bool useStaticController;

  static final ScrollController scrollController = ScrollController();
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool useGPT = UserPrivacy.useGPT;
  bool pushContent = UserPrivacy.pushContent;
  bool useGoogleDriveBackup = UserPrivacy.googleDriveBackup;
  bool promptProof = UserPrivacy.promptTransactionProof;
  bool useThirdPartyGPT = UserPrivacy.useThirdPartyGPT;

  final ScrollController scrollController = ScrollController();
  //String backupFrequency =

  bool privacy_updated = false;
  String privacy_message = '';
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

  @override
  void initState() {
    super.initState();

    if (widget.gotoPrivacy) {
      _scrollToBottom();
    }
    loadData();
  }

  bool _isOperationInProgress = false; // Add this at the start of the class

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var controller = widget.useStaticController
          ? ProfilePage.scrollController
          : scrollController;
      controller.position.maxScrollExtent;
      if (controller.hasClients) {
        await controller.animateTo(
          controller.position.maxScrollExtent - ResStyle.height * 0.2,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> updateUserPrivacy() async {
    if (!UserToken.online) {
      privacy_updated = true;
      privacy_message = 'No Connection.Unable to save changes';
      setState(() {});
      return;
    }

    // UserPrivacy.useGPT = useGPT;
    // UserPrivacy.pushContent = pushContent;
    // UserPrivacy.backUpFrequency = backupFrequency;
    privacy_updated = true;

    privacy_message = 'You have unsaved changes.';
    setState(() {});
    // await UserPrivacy.saveToPreferences(UserToken.user_code!);
  }

  Future<void> saveUserPrivacy() async {
    privacy_updated = false;
    _isOperationInProgress = true;
    setState(() {});
    var res = await AuthRepo.updateUserPrivacy(jsonEncode(UserPrivacy.toMap()));

    if (res) {
      try {
        UserPrivacy.useGPT = useGPT;
        UserPrivacy.pushContent = pushContent;
        UserPrivacy.googleDriveBackup = useGoogleDriveBackup;
        UserPrivacy.promptTransactionProof = promptProof;
        UserPrivacy.useThirdPartyGPT = useThirdPartyGPT;
        setState(() {});

        await UserPrivacy.saveToPreferences(UserToken.user_code!);
        await AuthRepo.updateUserPrivacy(jsonEncode(UserPrivacy.toMap()));

        BlocProvider.of<FinancialBloc>(context).add(FinancialLoadData());
        BlocProvider.of<ContentBloc>(context).add(ContentRequest());

        BlocProvider.of<MessageBloc>(context).add(CheckMessageEvent());
        BlocProvider.of<AuthBloc>(context).add(UserPrivacyUpdated());

        showTopSnackBar(context, 'Your Privacy Setting update successfully', 5);
      } catch (e) {
        try {
          showTopSnackBar(context, e.toString(), 5);
          await loadData();
        } catch (e) {}
      }
    } else {
      privacy_updated = true;
      setState(() {});
      try {
        BlocProvider.of<FinancialBloc>(context).add(FinancialLoadData());
        BlocProvider.of<ContentBloc>(context).add(ContentRequest());
        BlocProvider.of<AuthBloc>(context).add(UserPrivacyUpdated());
        BlocProvider.of<MessageBloc>(context).add(CheckMessageEvent());
        showTopSnackBar(
            context, 'Oops. We are failed to update your Privacy Setting.', 5);
      } catch (e) {}
    }
  }

  Future<void> logOut() async {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    BlocProvider.of<AuthBloc>(context).add(LogoutRequested());
  }

  Future<void> loadData() async {
    if (!UserToken.online) {
      return;
    }

    var data = await AuthRepo.getProfile();

    if (data['success'] ?? false) {
      user = data['user_info'] as UserInfo;
      useGPT = UserPrivacy.useGPT;
      pushContent = UserPrivacy.pushContent;
      useGoogleDriveBackup = UserPrivacy.googleDriveBackup;
      promptProof = UserPrivacy.promptTransactionProof;
      useThirdPartyGPT = UserPrivacy.useThirdPartyGPT;
      setState(() {});
    }
  }

  void showChangePasswordDialog() async{
    if (!UserToken.online) {
      showTopSnackBar(
          context, 'Connection time out. Please try to restart the app', 5);

      return;
    }
    final _formKey = GlobalKey<FormState>();
   await  showModalBottomSheet(
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

    FocusScope.of(context).unfocus();
  }

  void fetchAddress(TextEditingController addressController,
      TextEditingController stateController, List<String> state_list) async {
    var addr = await LocationHelper.getAddress();

    if (addr.isEmpty) {
      return;
    }
    addressController.text = addr.join(',');

    var list = state_list.where((e) => e.contains(addr.last)).toList();

    if (list.isEmpty) {
      return;
    }

    if (list.length == 1) {
      stateController.text = list.first;
      //state_value = stateController.text;

      return;
    }

    list = state_list.where((e) => e.contains(addr[addr.length - 2])).toList();

    if (list.isNotEmpty) {
      stateController.text = list.first;
      // state_value = stateController.text;

      return;
    }
  }

  void showUpdateProfileDialog() async {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final stateController = TextEditingController(text: user.state);
    final addressController = TextEditingController(text: user.address);
    final telnoController = TextEditingController(text: user.telno);
    final emailController = TextEditingController(text: user.email);
    final _focusNode = FocusNode();
    final states_list = await AuthRepo.getStateList();

    String state_value = '';
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
            additionHeight: ResStyle.height * 0.15,
            header: "Update Profile",
            widgets: [
              BugTextInput(
                controller: emailController,
                label: "Email cannot be changed",
                hint: "Email cannot be changed",
                prefixIcon: Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),
              SizedBox(
                height: ResStyle.spacing,
              ),
              BugTextInput(
                controller: nameController,
                label: "Name",
                hint: "Enter your full name",
                prefixIcon: Icon(Icons.person),
              ),
              SizedBox(
                height: ResStyle.spacing,
              ),
              BugTextInput(
                controller: telnoController,
                label: "Telephone Number",
                hint: "Enter your telephone number",
                keyboardType: TextInputType.phone,
                prefixIcon: Icon(Icons.phone),
                maxLength: 13,
                validator: (value) {
                  final phoneRegex = RegExp(r'^\+60\d{9,11}$');
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  } else if (value.length < 12 || value.length > 13) {
                    return 'Invalid Phone Number';
                  } else if (!phoneRegex.hasMatch(value)) {
                    return 'Phone number must start with +60';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: ResStyle.spacing,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RawAutocomplete<String>(
                    textEditingController: stateController,
                    focusNode: _focusNode,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      var list = states_list
                          .where((state) =>
                              state.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase()) ||
                              textEditingValue.text
                                  .toLowerCase()
                                  .contains(state.toLowerCase()))
                          .toList();

                      if (list.isEmpty) {
                        list = states_list;
                      }
                      return list;
                    },
                    onSelected: (selection) {
                      var modification = (state_value != selection);
                      stateController.text = state_value = selection;

                      if (modification) {
                        addressController.text = '';
                      }
                      _focusNode.unfocus();
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      return BugTextInput(
                        controller: controller,
                        focusNode: focusNode,
                        label: "State",
                        hint: "Enter your state name",
                        prefixIcon: const Icon(Icons.map_outlined),
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              fetchAddress(addressController, stateController,
                                  states_list);
                            }),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your state name';
                          } else if (!states_list.contains(value)) {
                            return 'Invalid State';
                          }
                          return null;
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final list = options.toList();

                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 200,
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shrinkWrap: true,
                              itemCount: list.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final option = list[index];
                                final isExactMatch = option.toLowerCase() ==
                                    stateController.text.toLowerCase();

                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResStyle.spacing,
                                      vertical: ResStyle.spacing,
                                    ),
                                    color: HIGHTLIGHT_COLOR,
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: ResStyle.body_font,
                                        color: TEXT_COLOR,
                                        fontWeight: isExactMatch
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: ResStyle.spacing),
                  BugTextInput(
                    controller: addressController,
                    label: "Address",
                    hint: "Enter your address",
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    maxLine: 3,
                    fontSize: ResStyle.medium_font,
                  ),
                ],
              ),
              SizedBox(height: ResStyle.spacing),
              BugPrimaryButton(
                  color: TITLE_COLOR,
                  text: 'Save',
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    _isOperationInProgress = true;
                    setState(() {});
                    BlocProvider.of<AuthBloc>(context).add(
                      UpdateProfileRequest(
                        name: nameController.text,
                        state: stateController.text,
                        address: addressController.text,
                        telno: telnoController.text,
                      ),
                    );
                    
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

  Future<void> showRestoreDialog(BuildContext context) async {
    if (!UserPrivacy.googleDriveBackup) {
      showTopSnackBar(
          context,
          'To restore data, you need to grant permission for Google Drive backup.',
          5);

      return;
    }
    List<Map<String, dynamic>> backups =
        await GoogleDriveBackupHelper.readJsonFile();

    if (backups.isEmpty) {
      print("No backups found.");
      return;
    }

    // Show a dialog with available backups
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Backup to Restore"),
          content: SingleChildScrollView(
            child: ListBody(
              children: backups.map((backup) {
                return ListTile(
                  title: Text("Backup at: ${backup['backup_at']}"),
                  onTap: () async {
                    BlocProvider.of<AuthBloc>(context)
                        .add(UserStartRestore(backupData: backup));
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool pop) async {
        // Show the confirmation dialog when user presses the back button
       if(pop){
        return;
       }

        if (_isOperationInProgress) {
          showTopSnackBar(
              context, 'Please wait your operation is completing', 5);
        }else{
            Navigator.of(context).pop();
        }
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthChangePasswordResult) {
            // ScaffoldMessenger.of(context)
            //     .showSnackBar(BugSnackBar(state.message, 5));
            showTopSnackBar(context, state.message, 5);
            if (state.success) {
              logOut();
            }
          } else if (state is AuthUpdateProfileResult) {
            showTopSnackBar(context, state.message, 5);
            _isOperationInProgress = false;
            loadData();
          } else if (state is UserPrivacyReload) {
            _isOperationInProgress = false;

            loadData();
          }
        },
        child: Scaffold(
          appBar: BugAppBar(
            'Your Profile',
            context,
            show_icon: false,
          ),
          backgroundColor: HIGHTLIGHT_COLOR,
          body: Padding(
            padding: EdgeInsets.only(
              left: ResStyle.spacing,
              right: ResStyle.spacing,
              top: ResStyle.spacing,
            ),
            child: SingleChildScrollView(
              controller: widget.useStaticController
                  ? ProfilePage.scrollController
                  : scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Information Card
                  Card(
                    key:
                        (widget.useGKey) ? TutorialHelper.profileKeys[1] : null,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: HIGHTLIGHT_COLOR.withOpacity(0.85),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                            (UserToken.online)
                                ? BugRoundButton(
                                    key: (widget.useGKey)
                                        ? TutorialHelper.profileKeys[2]
                                        : null,
                                    icon: Icons.edit,
                                    onPressed: showUpdateProfileDialog,
                                    size: ResStyle.spacing * 3)
                                : Container(),
                            //SizedBox(width:  ResStyle.spacing/2,)
                          ],
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(ResStyle.spacing),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Privacy Settings',
                                    style: TextStyle(
                                        fontSize: ResStyle.body_font,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  if (privacy_updated)
                                    Text(
                                      privacy_message,
                                      style: TextStyle(
                                          fontSize: ResStyle.small_font,
                                          color: DANGER_COLOR),
                                      softWrap:
                                          true, // Allows text to wrap to the next line
                                      overflow: TextOverflow
                                          .visible, // Ensures text doesn't get clipped
                                    ),
                                ],
                              ),
                            ),
                            (privacy_updated && UserToken.online)
                                ? BugRoundButton(
                                    icon: Icons.save,
                                    label: 'Save',
                                    onPressed: saveUserPrivacy,
                                    color: SUCCESS_COLOR,
                                    text_color: HIGHTLIGHT_COLOR,
                                    icon_color: HIGHTLIGHT_COLOR,
                                    size: ResStyle.spacing * 3)
                                : Container(),
                          ],
                        ),
                        const Divider(),
                        CardWidgetivider(
                          key: (widget.useGKey)
                              ? TutorialHelper.profileKeys[3]
                              : null,
                          'Allow xBUG AI Financial Assitant Using Your Data',
                          BugSwitch(
                            value: useGPT,
                            onChanged: (value) {
                              setState(() {
                                useGPT = value;
                                useThirdPartyGPT = value && useThirdPartyGPT;
                              });
                              updateUserPrivacy();
                            },
                          ),
                        ),

                        CardWidgetivider(
                          key: (widget.useGKey)
                              ? TutorialHelper.profileKeys[4]
                              : null,
                          'Allow Third Party AI Financial Assitant Using Your Data for Higher Performance',
                          BugSwitch(
                            value: useThirdPartyGPT,
                            onChanged: (value) {
                              setState(() {
                                //useThirdPartyGPT = value;
                                useThirdPartyGPT = value && useGPT;
                              });
                              updateUserPrivacy();
                            },
                          ),
                        ),
                        CardWidgetivider(
                            key: (widget.useGKey)
                                ? TutorialHelper.profileKeys[5]
                                : null,
                            'Enable Content Browsing and Receiving Recommendations',
                            BugSwitch(
                              value: pushContent,
                              onChanged: (value) {
                                setState(() {
                                  pushContent = value;
                                });
                                updateUserPrivacy();
                              },
                            )),
                        // CardWidgetivider(
                        //   'Backup',
                        //   DropdownButton<String>(
                        //     dropdownColor: HIGHTLIGHT_COLOR,
                        //     value: backupFrequency,
                        //     items: [
                        //       "No Backup",
                        //       "First Transaction In A Day",
                        //       "First Transaction In A Month",
                        //       "Every Transaction",
                        //     ].map((String value) {
                        //       return DropdownMenuItem<String>(
                        //         value: value,
                        //         child: Text(value),
                        //       );
                        //     }).toList(),
                        //     onChanged: (newValue) {
                        //       if (newValue != null) {
                        //         setState(() {
                        //           backupFrequency = newValue;
                        //         });
                        //         updateUserPrivacy();
                        //       }
                        //     },
                        //   ),
                        // ),
                        CardWidgetivider(
                          key: (widget.useGKey)
                              ? TutorialHelper.profileKeys[6]
                              : null,
                          'Always Prompt You to Add Transaction Proof',
                          BugSwitch(
                            value: promptProof,
                            onChanged: (value) {
                              setState(() {
                                promptProof = value;
                              });
                              updateUserPrivacy();
                            },
                          ),
                        ),

                        CardWidgetivider(
                          key: (widget.useGKey)
                              ? TutorialHelper.profileKeys[7]
                              : null,
                          'Allow to use your Google Drive to backup your data',
                          BugSwitch(
                            value: useGoogleDriveBackup,
                            onChanged: (value) {
                              setState(() {
                                useGoogleDriveBackup = value;
                              });
                              updateUserPrivacy();
                            },
                          ),
                        ),

                        BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                          if (state is UserBackUpRunning) {
                            return CardWidgetivider(
                              'Back up in progress...',
                              Expanded(
                                child: LinearProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      SUCCESS_COLOR),
                                ),
                              ),
                            );
                          } else {
                            return CardWidgetivider(
                                'Your data will backup automatically everyday',
                                BugIconButton(
                                    text: 'Backup now',
                                    onPressed: () async {
                                      BlocProvider.of<AuthBloc>(context)
                                          .add(UserStartBackup());
                                    },
                                    icon: Icons.backup));
                          }
                        }),

                        BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                          if (state is UserRestoreRunning) {
                            return CardWidgetivider(
                              'Restore in progress...',
                              Expanded(
                                child: LinearProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      SUCCESS_COLOR),
                                ),
                              ),
                            );
                          } else {
                            return CardWidgetivider(
                                'Last Backup: ${UserBackup.lastBackUpTime?.toString().substring(0, 16) ?? ''}',
                                BugIconButton(
                                    text: 'Restore now',
                                    onPressed: () {
                                      showRestoreDialog(context);
                                    },
                                    icon: Icons.restore),
                                isLast: true);
                          }
                        }),

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
                            key: (widget.useGKey)
                                ? TutorialHelper.profileKeys[8]
                                : null,
                            text: "Tour Guide",
                            onPressed: () {
                              while (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                              BlocProvider.of<AuthBloc>(context)
                                  .add(UserTourGuide());
                            },
                            color: RM1_COLOR),
                        SizedBox(height: ResStyle.spacing),
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
      ),
    );
  }
}
