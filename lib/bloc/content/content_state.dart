part of 'content_bloc.dart';

sealed class ContentState{
  const ContentState();
  
 
}
final class ContentTestState extends ContentState {}

final class ContentReadyState extends ContentState {}

final class ContentLoadingState extends ContentState {}


// final class NextContentState extends ContentState {
//   final Content content;

//   NextContentState({required this.content});

// }

// final class ContentSubmittedState extends ContentState{}



// class ExampleState extends TemplateState {
//   final String error;

//   const ExampleState(this.error);

//   @override
//   List<Object> get props => [error];
// }

