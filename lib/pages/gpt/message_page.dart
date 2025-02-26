import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/gold_leaf_bloc/gold_leaf_bloc.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';
import 'package:build_growth_mobile/models/chat_history.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/pages/auth/profile_page.dart';
import 'package:build_growth_mobile/pages/gpt/star_message_page.dart';
import 'package:build_growth_mobile/pages/map/place_selection_page.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isScrolling = false;
  void _scrollToBottom() {
    if (isScrolling) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_scrollController.hasClients) {
        isScrolling =true;
         await Future.delayed(Duration(milliseconds: 100));
        while (_scrollController.position.pixels !=
            _scrollController.position.maxScrollExtent) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
          await Future.delayed(Duration(milliseconds: 100));
          
        }
        isScrolling =false;
      }
      
    });
  }
  

  void showMenu(int index) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await Clipboard.setData(
                  ClipboardData(text: MessageBloc.gptReplies[index]));
              ScaffoldMessenger.of(context).showSnackBar(
                  BugSnackBar('Copy the message successfully', 5));
            },
            child: Text('Copy This Message',
                style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font)),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              var gpt = MessageBloc.gptReplies[index];
              var user = MessageBloc.userMessages[index];
              Chat_History chat = Chat_History(
                  DateTime.now(), '1', UserToken.user_code,
                  request: user, response: gpt, transaction_id: null);

              await Chat_History.insertChatHistory(chat);

              ScaffoldMessenger.of(context).showSnackBar(
                  BugSnackBar('Star the message successfully', 5));
            },
            child: Text('Star This Message',
                style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font)),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => StarMessagePage()));
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Text('View Star Messages',
                style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel',
              style: TextStyle(color: DANGER_COLOR, fontSize: ResStyle.font)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: BugAppBarWithContainer('Financial Assistant', context,
          containerChild:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            // Text('By using this service, I acknowledge that my data may be shared with third parties to enhance response performance.'),
            if (UserPrivacy.useGPT)
              (UserPrivacy.useThirdPartyGPT)
                  ? BugSmallButton(
                      text: 'Use xBUG Self-Hosted Assistant',
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfilePage(
                                  gotoPrivacy: true,
                                )));

                        FocusScope.of(context).unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                      })
                  : BugSmallButton(
                      text: 'Use Third Party Assistant',
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfilePage(
                                  gotoPrivacy: true,
                                )));

                        FocusScope.of(context).unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                      }),
            BugSmallButton(
                text: 'View Star Message',
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => StarMessagePage()));

                  FocusScope.of(context).unfocus();
                  FocusManager.instance.primaryFocus?.unfocus();
                }),
          ])),
      backgroundColor: HIGHTLIGHT_COLOR,
      body: BlocListener<MessageBloc, MessageState>(
        listener: (context, state) {
          if (state is MessageInitial) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Chat reset!")),
            );
          } else if (state is MessageSendError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is MessageReply) {
            _scrollToBottom();
          } else if (state is MessageChecked) {
            setState(() {});
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Chat content area (messages)
              if (UserPrivacy.useGPT) ...[
                Expanded(
                  child: BlocBuilder<MessageBloc, MessageState>(
                    builder: (context, state) {
                      final messages = _buildMessages(context, state);
                      return Padding(
                        padding: EdgeInsets.only(
                            right: ResStyle.spacing,
                            left: ResStyle.spacing,
                            top: ResStyle.spacing),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) => messages[index],
                        ),
                      );
                    },
                  ),
                ),
                // Input field area that adjusts based on keyboard visibility
                SizedBox(
                  height: ResStyle.spacing / 2,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context)
                        .viewInsets
                        .bottom, // Adjust padding based on keyboard
                  ),
                  child: _buildInputField(context),
                ),
              ] else ...[
                _systemMessage('Financial Service Unavailable'),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: ResStyle.spacing,
                        left: ResStyle.spacing,
                        top: ResStyle.spacing),
                    child: Column(
                      children: [
                        _gptMessage(
                            "Oh no! 😢 You've cut off our connection. To get your financial assistant buzzing again, just enable it in your profile page! 💸✨",
                            -1),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(ResStyle.spacing),
                  child: BugPrimaryButton(
                      text: 'Enable Financial Assistant',
                      color: TITLE_COLOR,
                      onPressed: () {
                        redirectToProfile(context, true);
                      }),
                ),
                SizedBox(
                  height: ResStyle.spacing * 3,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMessages(BuildContext context, MessageState state) {
    final userMessages = MessageBloc.userMessages;
    final gptReplies = MessageBloc.gptReplies;

    final List<Widget> widgets = [
      _systemMessage("GPT: Hello, I am willing to answer your questions"),
    ];

    for (int i = 0; i < userMessages.length; i++) {
      widgets.add(_userMessage(userMessages[i]));
      if (i < gptReplies.length) {
        widgets.add(_gptMessage(gptReplies[i], i));
      }
    }

    if (state is MessageSending) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }

    return widgets;
  }

  Widget _systemMessage(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ResStyle.spacing),
        child: Text(
          message,
          style: TextStyle(
            fontSize: ResStyle.medium_font,
            fontStyle: FontStyle.italic,
            color: PRIMARY_COLOR,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _userMessage(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(left: ResStyle.spacing * 2),
        padding: EdgeInsets.all(ResStyle.spacing / 2),
        decoration: BoxDecoration(
          color: RM1_COLOR,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: ResStyle.medium_font, color: TEXT_COLOR),
        ),
      ),
    );
  }

  Widget _gptMessage(String message, int index) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            if (state is MessageSending || state is MessageReply) {
              return;
            }

            if (index > 0 && index < MessageBloc.gptReplies.length) {
              showMenu(index);
            }
          },
          child: BugEmoji(message: message),
        );
      },
    );
  }

  Widget _buildInputField(BuildContext context) {
    List<String> quickReplies = [
      'My Budget Plan',
      'Budget Places',
      'Investment Tips',
      'Savings Advice'
    ];
    ScrollController controller = ScrollController();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: controller,
                child: Row(
                  children: quickReplies.map((label) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ResStyle.spacing / 2),
                      child: BugSmallButton(
                          text: label,
                          onPressed: () async {
                            if (label == 'Budget Places') {
                              await Navigator.of(context).push(
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          PlaceSelectionPage()));
                              FocusScope.of(context).unfocus();
                              FocusManager.instance.primaryFocus?.unfocus();
                            } else if (label == 'My Budget Plan') {
                              BlocProvider.of<MessageBloc>(context).add(
                                  SendMessageEvent(
                                      'Based on my cashflow, suggest the detailed budget plan for today, this month, and yearly goal'));
                              BlocProvider.of<GoldLeafBloc>(context)
                                  .add(ChatGoldLeafEvent());
                            } else if (label == 'Investment Tips') {
                              BlocProvider.of<MessageBloc>(context).add(
                                  SendMessageEvent(
                                      'Based on my cashflow, suggest the short-term and long-term detailed investment plan that suitable for me'));
                              BlocProvider.of<GoldLeafBloc>(context)
                                  .add(ChatGoldLeafEvent());
                            } else if (label == 'Savings Advice') {
                              BlocProvider.of<MessageBloc>(context).add(
                                  SendMessageEvent(
                                      'Based on my cashflow and expense behaviour, what is the critical saving advice for me?'));
                              BlocProvider.of<GoldLeafBloc>(context)
                                  .add(ChatGoldLeafEvent());
                            } else {
                              BlocProvider.of<MessageBloc>(context)
                                  .add(SendMessageEvent(label));
                              BlocProvider.of<GoldLeafBloc>(context)
                                  .add(ChatGoldLeafEvent());
                            }
                          },
                          color: RM50_COLOR),
                    );
                  }).toList(),
                ),
              ),
            ),
            // More indicator

            BugRoundButton(
                icon: Icons.more_horiz_sharp,
                size: ResStyle.body_font,
                text_color: RM50_COLOR,
                color: HIGHTLIGHT_COLOR,
                onPressed: () {
                  if (controller.position.pixels ==
                      controller.position.maxScrollExtent) {
                    controller.animateTo(
                      0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  } else {
                    controller.animateTo(
                      controller.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                }),
            // Icon(
            //   Icons.more_horiz,
            //   size: ResStyle.font,
            //   color: Colors.grey.shade500,
            // ),
            SizedBox(
              width: ResStyle.spacing / 2,
            )
          ],
        ),
        Container(
          color: Colors.white,
          padding:
              EdgeInsets.symmetric(horizontal: ResStyle.spacing, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  cursorColor: TITLE_COLOR,
                  onChanged: (value) {
                    setState(() {});
                  },
                  style: TextStyle(fontSize: ResStyle.medium_font),
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                  ),
                  onTap: _scrollToBottom,
                ),
              ),
              BlocBuilder<MessageBloc, MessageState>(
                builder: (context, state) {
                  var isSending = (state is MessageSending ||
                      state is MessageReply ||
                      state is MessageInitial);

                  return IconButton(
                    icon: isSending
                        ? SizedBox(
                            width: ResStyle.spacing,
                            height: ResStyle.spacing,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: RM50_COLOR,
                            ),
                          )
                        : Icon(Icons.send,
                            color: _controller.text.isEmpty
                                ? RM50_COLOR
                                : TITLE_COLOR),
                    onPressed: isSending || _controller.text.isEmpty
                        ? null
                        : () {
                            final message = _controller.text.trim();
                            if (message.isNotEmpty) {
                              BlocProvider.of<MessageBloc>(context).add(
                                SendMessageEvent(message),
                              );
                              BlocProvider.of<GoldLeafBloc>(context)
                                  .add(ChatGoldLeafEvent());
                              if (state is MessageSending ||
                                  state is MessageReply) {
                                return;
                              }
                              _controller.clear();
                              FocusScope.of(context).unfocus();
                            }
                          },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
