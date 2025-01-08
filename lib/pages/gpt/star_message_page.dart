import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';
import 'package:build_growth_mobile/models/chat_history.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StarMessagePage extends StatefulWidget {
  const StarMessagePage({super.key});

  @override
  State<StarMessagePage> createState() => _StarMessagePageState();
}

class _StarMessagePageState extends State<StarMessagePage> {
  List<Chat_History> list = [];

  @override
  void initState() {
    super.initState();
    loadata();
  }

  void loadata() async {
    list = await Chat_History.getChatList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BugAppBar('Starred Message', context),
        backgroundColor: HIGHTLIGHT_COLOR,
        body: (list.isEmpty)
            ? Center(
                child: Text('No Starred Message'),
              )
            : Padding(
                padding: EdgeInsets.all(ResStyle.spacing),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...list.map((chat) => GestureDetector(
                            onTap: () async {
                              await showCupertinoModalPopup<void>(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoActionSheet(
                                  actions: <CupertinoActionSheetAction>[
                                    CupertinoActionSheetAction(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await Clipboard.setData(ClipboardData(
                                            text:
                                                '[${chat.create_at.toString()}]\nYou: ${chat.request} \n\nResponse: ${chat.response}'));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(BugSnackBar(
                                                'Copy the message successfully',
                                                5));
                                      },
                                      child: Text('Copy This Message',
                                          style: TextStyle(
                                              color: TITLE_COLOR,
                                              fontSize: ResStyle.font)),
                                    ),
                                    CupertinoActionSheetAction(
                                      onPressed: () async {
                                        Navigator.pop(context);

                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return BugInfoDialog(
                                              title: 'Delete Confirmation',
                                              main_color:
                                                  DANGER_COLOR, // Set a color for the delete confirmation
                                              message:
                                                  'Are you sure you want to delete this message?',
                                              actions: [
                                                BugPrimaryButton(
                                                    onPressed: () async {
                                                      // Perform delete action here

                                                      await Chat_History
                                                          .deleteChatHistory(
                                                              chat.id ?? 0);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(BugSnackBar(
                                                              'Starred message removed',
                                                              5));
                                                      loadata();
                                                    },
                                                    text: 'Delete',
                                                    color: DANGER_COLOR),
                                                SizedBox(
                                                  height: ResStyle.spacing,
                                                ),
                                                BugPrimaryButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                    text: 'Cancel',
                                                    color: PRIMARY_COLOR),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text('Remove This Starred Message',
                                          style: TextStyle(
                                              color: DANGER_COLOR,
                                              fontSize: ResStyle.font)),
                                    ),
                                  ],
                                  cancelButton: CupertinoActionSheetAction(
                                    isDefaultAction: true,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel',
                                        style: TextStyle(
                                            color: DANGER_COLOR,
                                            fontSize: ResStyle.font)),
                                  ),
                                ),
                              );
                            },
                            child: BugEmoji(
                                message:
                                    '[${chat.create_at.toString()}]\nYou: ${chat.request} \n\nResponse: ${chat.response}'),
                          )),
                    ],
                  ),
                ),
              ));
  }
}
