part of 'content_bloc.dart';

sealed class ContentEvent {
  const ContentEvent();
}


class ContentRequest extends ContentEvent {}

class SubmitContentTestEvent extends ContentEvent {

  final List<Content> like_list;
  final List<Content> dislike_list;

  SubmitContentTestEvent({required this.like_list, required this.dislike_list});

  
}

class ContentRebuildEvent extends ContentEvent{}



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
