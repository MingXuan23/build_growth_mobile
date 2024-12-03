import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:build_growth_mobile/api_services/content_repo.dart';
import 'package:build_growth_mobile/models/content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'content_event.dart';
part 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {


  ContentBloc(ContentState intial) : super(intial) {
    on<ContentRequest>((event, emit) async {
       await ContentRepo.fetchVectorContent();
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
