import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';
import 'package:build_growth_mobile/models/chat_history.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/models/user_token.dart';
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
        await Future.delayed(Duration(milliseconds: 120));

        if (_scrollController.position.pixels !=
            _scrollController.position.maxScrollExtent) {
          _scrollToBottom();
        }
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
                await Clipboard.setData(ClipboardData(text: MessageBloc.gptReplies[index]));
              ScaffoldMessenger.of(context).showSnackBar(BugSnackBar('Copy the message successfully', 5));
            },
            child: Text('Copy This Message',
                style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font)),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              var gpt =MessageBloc.gptReplies[index];
              var user = MessageBloc.userMessages[index];
              Chat_History chat = Chat_History(DateTime.now(), '1', UserToken.user_code, request: user, response: gpt, transaction_id: null);

              await Chat_History.insertChatHistory(chat);

              ScaffoldMessenger.of(context).showSnackBar(BugSnackBar('Star the message successfully', 5));
            },
            child: Text('Star This Message',
                style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font)),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=> StarMessagePage()));
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
      appBar: BugAppBar('Financial Assistant', context),
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
                            "Oh no! 😢 You've cut off our connection. To get your financial assistant buzzing again, just enable it in your profile page! 💸✨", -1),
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
        widgets.add(_gptMessage(gptReplies[i],i));
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

            if(index > 0 && index < MessageBloc.gptReplies.length){
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
                          onPressed: () {
                            if (label == 'Budget Places') {
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (context) => PlaceSelectionPage()));
                            } else if (label == 'My Budget Plan') {
                              BlocProvider.of<MessageBloc>(context).add(
                                  SendMessageEvent(
                                      'Based on my cashflow, suggest the budget plan for today, this month, and this year'));
                            } else if (label == 'Investment Tips') {
                              BlocProvider.of<MessageBloc>(context).add(
                                  SendMessageEvent(
                                      'Based on my cashflow, suggest the short-term and long-term investment plan that suitable for me'));
                            } else if (label == 'Savings Advice') {
                              BlocProvider.of<MessageBloc>(context).add(
                                  SendMessageEvent(
                                      'Based on my cashflow and expense behaviour, what is the critical saving advice for me?'));
                            } else {
                              BlocProvider.of<MessageBloc>(context)
                                  .add(SendMessageEvent(label));
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
