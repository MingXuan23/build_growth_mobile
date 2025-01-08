part of 'content_bloc.dart';

sealed class ContentState {
  const ContentState();
}

final class ContentTestState extends ContentState {
  final List<Content> list;

  ContentTestState({required this.list});
}

final class ContentReadyState extends ContentState {
  final List<Content> list;
  final List<String> recommendations;

  ContentReadyState( {required this.list, required this.recommendations });
}

final class ContentLoadingState extends ContentState {}

final class ContentTestResultState extends ContentState {
  final String message;

  ContentTestResultState({required this.message});
}



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

