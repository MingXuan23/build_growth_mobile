part of 'content_init_bloc.dart';

sealed class ContentInitEvent {
  const ContentInitEvent();
}


class LoadContentEvent extends ContentInitEvent {

}

class SwipeContentEvent extends ContentInitEvent{

  final bool isLiked;

  SwipeContentEvent({ required this.isLiked});
}

class SubmitContentEvent extends ContentInitEvent {
  final List<Content> likedContents;
   final List<Content> dislikedContents;

  const SubmitContentEvent({
    required this.likedContents,
    required this.dislikedContents,
  });

  @override
  List<Object> get props => [likedContents, dislikedContents];
}



class ResetContentEvent extends ContentInitEvent {
  final List<Content> contentList;

  ResetContentEvent({required this.contentList});
  
}