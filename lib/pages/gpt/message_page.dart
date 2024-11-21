import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:flutter/material.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BugAppBar('Financial Assistant', context),
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
          }
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<MessageBloc, MessageState>(
                builder: (context, state) {
                  final messages = _buildMessages(context, state);
                  return Padding(
                    padding: EdgeInsets.all(ResStyle.spacing),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                    
                      itemBuilder: (context, index) => messages[index],
                    ),
                  );
                },
              ),
            ),
            _buildInputField(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMessages(BuildContext context, MessageState state) {
    final bloc = BlocProvider.of<MessageBloc>(context);
    final userMessages = bloc.userMessages;
    final gptReplies = bloc.gptReplies;

    final List<Widget> widgets = [
      _systemMessage("GPT: Hello, I am willing to answer your questions"),
    ];

    for (int i = 0; i < userMessages.length; i++) {
      widgets.add(_userMessage(userMessages[i]));
      if (i < gptReplies.length) {
        widgets.add(_gptMessage(gptReplies[i]));
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
        padding:  EdgeInsets.symmetric(vertical: ResStyle.spacing),
        child: Text(
          message,
          style:  TextStyle(
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
        margin:  EdgeInsets.symmetric(vertical: ResStyle.small_font),
        padding:  EdgeInsets.all(ResStyle.spacing),
        decoration:  const BoxDecoration(
        color: RM1_COLOR,
          borderRadius:  BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Text(
          message,
           style: TextStyle(fontSize: ResStyle.font, color: TEXT_COLOR),
        ),
      ),
    );
  }

  Widget _gptMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin:  EdgeInsets.symmetric(vertical: ResStyle.small_font),
        padding:  EdgeInsets.all(ResStyle.spacing),
        decoration: BoxDecoration(
          color:RM1_COLOR.withOpacity(0.4),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: ResStyle.font, color: TEXT_COLOR),
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: ResStyle.spacing, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
              ),
              onTap: _scrollToBottom,
            ),
          ),
          BlocBuilder<MessageBloc, MessageState>(
            builder: (context, state) {
              final isSending = state is MessageSending;
              return IconButton(
                icon: isSending
                    ?  SizedBox(
                        width: ResStyle.spacing,
                        height:  ResStyle.spacing,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send, color: TITLE_COLOR),
                onPressed: isSending
                    ? null
                    : () {
                        final message = _controller.text.trim();
                        if (message.isNotEmpty) {
                          BlocProvider.of<MessageBloc>(context).add(
                            SendMessageEvent(message),
                          );
                          _controller.clear();
                        }
                      },
              );
            },
          ),
        ],
      ),
    );
  }
}
