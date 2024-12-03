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

        contentList = [
          Content(
            id: 1,
            name: 'Sell a roti canai',
            desc: 'Beautiful food',
            image:
                'https://th.bing.com/th/id/OSK.HERO8XdjPgvg2B2GR7frcl-vej_iLDSTYeEoctNxHEj1i-g?rs=1&pid=ImgDetMain',
          ),
          Content(
            id: 2,
            name: 'Flutter Helper Class',
            desc: 'Breathtaking sunset over calm ocean waters',
            image:
                'https://uploads-ssl.webflow.com/5f841209f4e71b2d70034471/6078b650748b8558d46ffb7f_Flutter%20app%20development.png',
          ),
          Content(
            id: 3,
            name: 'Car boot Sale',
            desc: 'Peaceful forest path with tall green trees',
            image:
                'https://th.bing.com/th/id/OIP.LvWRZhK3bT-OQ-JTrATPpwHaGb?rs=1&pid=ImgDetMain',
          ),
        ];

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
          emit(ContentSubmittedState());
          return;
        }
        emit(NextContentState(
            content: contentList[likedList.length + dislikedList.length]));
      },
    );

    on<ResetContentEvent>(
      (event, emit) {
        contentList = [];
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
