import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:build_growth_mobile/models/content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'content_init_event.dart';
part 'content_init_state.dart';

class ContentInitBloc extends Bloc<ContentInitEvent, ContentInitState> {
  List<Content> contentList = [];
  List<Content> likedList = [];

  List<Content> dislikedList = [];

  ContentInitBloc(ContentInitState intial) : super(intial) {
    on<LoadContentEvent>(
      (event, emit) {
        emit(ContentInitLoadingState());
        likedList = [];

        dislikedList = [];

       

        emit(NextContentState(content: contentList[0]));
      },
    );

    on<SwipeContentEvent>(
      (event, emit) {
        if (event.isLiked) {
          likedList.add(contentList[likedList.length + dislikedList.length]);
        } else {
          dislikedList.add(contentList[likedList.length + dislikedList.length]);
        }

        if ((likedList.length + dislikedList.length) >= contentList.length) {
          emit(ContentSubmittedState(dislike_list: dislikedList,like_list: likedList));
          return;
        }
        emit(NextContentState(
            content: contentList[likedList.length + dislikedList.length]));
      },
    );

    on<ResetContentEvent>(
      (event, emit) {
        contentList = event.contentList;
        likedList = [];

        dislikedList = [];
        emit(ContentInitialState());
      },
    );
    // on<ExampleEvent>(
    //   (event, emit) {
    //     emit(TemplateInitial());
    //   },
    // );
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
