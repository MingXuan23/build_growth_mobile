part of 'content_bloc.dart';

sealed class ContentEvent {
  const ContentEvent();
}


class ContentRequest extends ContentEvent {}



// class SwipeContentEvent extends ContentEvent{

//   final bool isLiked;

//   SwipeContentEvent({ required this.isLiked});
// }

// class SubmitContentEvent extends ContentEvent {
//   final List<Content> likedContents;
//    final List<Content> dislikedContents;

//   const SubmitContentEvent({
//     required this.likedContents,
//     required this.dislikedContents,
//   });

//   @override
//   List<Object> get props => [likedContents, dislikedContents];
// }



class ResetContentEvent extends ContentEvent  {}