import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:build_growth_mobile/api_services/content_repo.dart';
import 'package:build_growth_mobile/bloc/content_init/content_init_bloc.dart';
import 'package:build_growth_mobile/models/content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'content_event.dart';
part 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  ContentBloc(ContentState intial) : super(intial) {
    on<ContentRequest>(
      (event, emit) async {
        emit(ContentLoadingState());
       var result =  await ContentRepo.loadContent();

       if(result['result'] == 201){
        List<Content> contentList = (result['list'] as List)
      .map((item) => item as Content)
      .toList();
        emit(ContentTestState(list: contentList));

       }else if(result['result'] == 200){
          List<Content> contentList = (result['list'] as List)
      .map((item) => item as Content)
      .toList();
        emit(ContentReadyState(list: contentList));
       }


  
       


      },
    );

    on<SubmitContentTestEvent>((event, emit) async {

      if(state is ContentLoadingState || state is ContentTestResultState){
        return;
      }
       emit(ContentLoadingState());

        var message = await ContentRepo.saveContentTest(event.like_list, event.dislike_list);

        emit(ContentTestResultState(message:  message));
    },);

    on<ContentRebuildEvent>((event, emit) {
      emit(ContentLoadingState());
      emit(state);
    },);
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
