part of 'content_init_bloc.dart';

sealed class ContentInitState{
  const ContentInitState();
  
 
}
final class ContentInitialState extends ContentInitState {}

final class ContentInitLoadingState extends ContentInitState {}

final class NextContentState extends ContentInitState {
  final Content content;

  NextContentState({required this.content});

}

final class ContentSubmittedState extends ContentInitState{
  final List<Content> dislike_list;
  final List<Content> like_list;

  ContentSubmittedState({required this.dislike_list, required this.like_list});

  

}



// class ExampleState extends TemplateState {
//   final String error;

//   const ExampleState(this.error);

//   @override
//   List<Object> get props => [error];
// }

