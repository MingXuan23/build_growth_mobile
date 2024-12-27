import 'dart:async';

import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:build_growth_mobile/api_services/gpt_repo.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
 static   List<String> userMessages = [];
  static  List<String> gptReplies = [];
  bool ready = false;
  StreamSubscription<String>? _streamSubscription;

  MessageBloc(MessageState messageInitial) : super(messageInitial) {
    on<SendMessageEvent>((event, emit) async {
      if (!UserPrivacy.useGPT) {
        gptReplies.add(
            'Oh no! 😢 You’ve cut off our connection. To get your financial assistant buzzing again, just enable it in your profile page! 💸✨');
        emit(MessageReply([...userMessages], [...gptReplies]));
        return;
      }
      if (state is MessageSending || state is MessageReply) {
        return;
      }
      emit(MessageSending());

      try {
        // Add user's message to the list
        userMessages.add(event.message);
        emit(MessageReply([...userMessages], [...gptReplies]));

        // Use a Completer to ensure the event handler doesn't complete prematurely
        final completer = Completer<void>();

        List<Map<String,dynamic>> chat_histoy = [];

        if(userMessages.length >=2){
          chat_histoy.add({"role":"user", "content":userMessages[userMessages.length -1 ]});
        }

        if(gptReplies.length >=2){
          chat_histoy.add({"role":"assistant", "content":gptReplies[gptReplies.length -1 ]});

        }
        // _streamSubscription = GptRepo.fastResponse(event.message, chat_histoy: chat_histoy).listen(
        //   (chunk) {
        //     // Append each chunk to the latest reply
        //     if (gptReplies.isEmpty ||
        //         gptReplies.last == '' ||
        //         gptReplies.length < userMessages.length) {
        //       gptReplies.add(chunk);
        //     } else {
        //       gptReplies[gptReplies.length - 1] += chunk;
        //     }

        //     // Emit the updated state
        //     emit(MessageReply([...userMessages], [...gptReplies]));
        //   },
        //   onError: (error) {
        //     emit(MessageSendError(error.toString()));
        //     completer.complete(); // Complete on error
        //   },
        //   onDone: () {
        //     // Handle when the stream ends
        //     if (gptReplies.isNotEmpty && gptReplies.last == '') {
        //       gptReplies.removeLast(); // Remove empty response, if any
        //     }
        //     emit(MessageReply([...userMessages], [...gptReplies]));
        //     completer.complete(); // Complete when done

        //     emit(MessageCompleted());
        //   },
        //   cancelOnError: true,
        // );

if(UserPrivacy.useThirdPartyGPT){
   _streamSubscription = GptRepo.quickResponse(event.message, chat_history: chat_histoy).listen(
          (chunk) {
            // Append each chunk to the latest reply
            if (gptReplies.isEmpty ||
                gptReplies.last == '' ||
                gptReplies.length < userMessages.length) {
              gptReplies.add(chunk);
            } else {
              gptReplies[gptReplies.length - 1] += chunk;
            }

            // Emit the updated state
            emit(MessageReply([...userMessages], [...gptReplies]));
          },
          onError: (error) {
            emit(MessageSendError(error.toString()));
            completer.complete(); // Complete on error
          },
          onDone: () {
            // Handle when the stream ends
            if (gptReplies.isNotEmpty && gptReplies.last == '') {
              gptReplies.removeLast(); // Remove empty response, if any
            }
            emit(MessageReply([...userMessages], [...gptReplies]));
            completer.complete(); // Complete when done

            emit(MessageCompleted());
          },
          cancelOnError: true,
        );

        // Wait for the stream to finish
        await completer.future;
}else{
   _streamSubscription = GptRepo.fastResponse(event.message, chat_history: chat_histoy).listen(
          (chunk) {
            // Append each chunk to the latest reply
            if (gptReplies.isEmpty ||
                gptReplies.last == '' ||
                gptReplies.length < userMessages.length) {
              gptReplies.add(chunk);
            } else {
              gptReplies[gptReplies.length - 1] += chunk;
            }

            // Emit the updated state
            emit(MessageReply([...userMessages], [...gptReplies]));
          },
          onError: (error) {
            emit(MessageSendError(error.toString()));
            completer.complete(); // Complete on error
          },
          onDone: () {
            // Handle when the stream ends
            if (gptReplies.isNotEmpty && gptReplies.last == '') {
              gptReplies.removeLast(); // Remove empty response, if any
            }
            emit(MessageReply([...userMessages], [...gptReplies]));
            completer.complete(); // Complete when done

            emit(MessageCompleted());
          },
          cancelOnError: true,
        );

        // Wait for the stream to finish
        await completer.future;
}
        
      } catch (error) {
        emit(MessageSendError(error.toString()));
      }
    });

on<CheckMessageEvent>((event, emit) {
  emit(MessageChecked());
},);
    on<RestartMessageEvent>((event, emit) {
      userMessages.clear();
      gptReplies.clear();
      ready = false;
      // Cancel any ongoing stream
      _streamSubscription?.cancel();
      _streamSubscription = null;

      emit(MessageInitial());
    });

    on<LoadMessageModel>(
      (event, emit) async {
        ready = await GptRepo.loadModel();
      },
    );
  }

  @override
  Future<void> close() {
    // Cancel the stream subscription when closing the Bloc
    _streamSubscription?.cancel();
    return super.close();
  }
}


//brief explanation

//user trigger a action and u should add the event to the bloc provider like this
/*BlocProvider.of<AuthBloc>(context).add(
        LoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      ); 
*/

//then u handle the event in the bloc class

//the state was emitted, the changes will listened by bloc listener in the pages

//after created a new bloc remember add it to the main.dart
