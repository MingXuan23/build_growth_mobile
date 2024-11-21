import 'dart:async';

import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:build_growth_mobile/api_services/gpt_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final List<String> userMessages = [];
  final List<String> gptReplies = [];
  bool ready = false;
  StreamSubscription<String>? _streamSubscription;

  MessageBloc(MessageState messageInitial) : super(messageInitial) {
    on<SendMessageEvent>((event, emit) async {
      emit(MessageSending());

      try {
        // Add user's message to the list
        userMessages.add(event.message);
        emit(MessageReply([...userMessages], [...gptReplies]));

        // Use a Completer to ensure the event handler doesn't complete prematurely
        final completer = Completer<void>();

        _streamSubscription =
            GptRepo.fastResponse(event.message).listen(
          (chunk) {
            // Append each chunk to the latest reply
            if (gptReplies.isEmpty || gptReplies.last == '' || gptReplies.length < userMessages.length) {
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
          },
          cancelOnError: true,
        );

        // Wait for the stream to finish
        await completer.future;
      } catch (error) {
        emit(MessageSendError(error.toString()));
      }
    });

    on<RestartMessageEvent>((event, emit) {
      userMessages.clear();
      gptReplies.clear();
      ready = false;
      // Cancel any ongoing stream
      _streamSubscription?.cancel();
      _streamSubscription = null;


      emit(MessageInitial());
    });

    on<LoadMessageModel>((event, emit)  async{
      ready = await GptRepo.loadModel();
    },);
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
