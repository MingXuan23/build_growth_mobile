import 'dart:math';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/content/content_bloc.dart';
import 'package:build_growth_mobile/bloc/content_init/content_init_bloc.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_emoji.dart';
import 'package:flutter/material.dart';
import 'package:build_growth_mobile/models/content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ContentInitPage extends StatefulWidget {

  const ContentInitPage({Key? key}) : super(key: key);

  @override
  _ContentInitPageState createState() => _ContentInitPageState();
}

class _ContentInitPageState extends State<ContentInitPage>
    with SingleTickerProviderStateMixin {
  // Swipe animation controller
  late AnimationController _animationController;
  late Animation<Offset> _swipeAnimation;
  Offset _dragOffset = Offset.zero;
  bool _isSwipeComplete = false;
  String  message =
              "Hooray, you're so close to discovering something awesome! 🏆Before you continue, there is a fun little personility test waiting for you. Let's ace it together! 🌟";



  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _checkVisibility();
  // }

  // @override
  // void didUpdateWidget(covariant ContentInitPage oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   _checkVisibility();
  // }

  void _checkVisibility() {
    setState(() {
          message =
              "Hooray, you're so close to discovering something awesome! 🏆Before you continue, there is a fun little personility test waiting for you. Let's ace it together! 🌟";
        });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finalizeSwipe();
      }
    });

   // BlocProvider.of<ContentInitBloc>(context).add(ResetContentEvent( widget.contentList));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _finalizeSwipe() {
    if (_isSwipeComplete) {
      bool isLiked = _dragOffset.dx > 0;
      BlocProvider.of<ContentInitBloc>(context)
          .add(SwipeContentEvent(isLiked: isLiked));
      setState(() {
        _dragOffset = Offset.zero;
        _isSwipeComplete = false;
      });
    }
    _animationController.reset();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeThreshold = screenWidth * 0.25;

    if (_dragOffset.dx.abs() > swipeThreshold) {
      // Trigger swipe animation
      _isSwipeComplete = true;
      _swipeAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset(
            _dragOffset.dx > 0 ? screenWidth * 1.5 : -screenWidth * 1.5, 0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward();
    } else {
      // Snap back to original position
      _animationController.reverse();
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  void _manualSwipe(bool isLiked) {
    final screenWidth = MediaQuery.of(context).size.width;
    _isSwipeComplete = true;
    _dragOffset = Offset(isLiked ? screenWidth : -screenWidth, 0);

    _swipeAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(isLiked ? screenWidth * 1.5 : -screenWidth * 1.5, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInBack,
    ));

    _animationController.forward();
  }

  Widget _buildSwipeIndicator() {
    // Calculate rotation and opacity based on drag offset
    double rotation =
        _dragOffset.dx / 500; // Adjust divisor to control rotation sensitivity
    Color indicatorColor = _dragOffset.dx > 0 ? SUCCESS_COLOR : DANGER_COLOR;

    return Align(
      alignment: Alignment.topCenter,
      child: Center(
        child: Opacity(
          opacity: max(min(_dragOffset.dx.abs() / 200, 1),
              0), // Fade in/out based on drag
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              padding: EdgeInsets.all(ResStyle.spacing),
              decoration: BoxDecoration(
                color: indicatorColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _dragOffset.dx > 0 ? 'LIKE' : 'DISLIKE',
                style: const TextStyle(
                  color: HIGHTLIGHT_COLOR,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BugAppBar('Content', context),
        backgroundColor: HIGHTLIGHT_COLOR,
        body: BlocBuilder<ContentInitBloc, ContentInitState>(
            builder: (context, state) {
          if (state is ContentInitialState) {
            return Padding(
              padding: EdgeInsets.all(ResStyle.spacing),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBugEmoji(message: message),
                  SizedBox(height: ResStyle.spacing,),
                  BugPrimaryButton(
                    color: TITLE_COLOR,
                      text: "Let's go >>",
                      onPressed: () {
                        BlocProvider.of<ContentInitBloc>(context)
                            .add(LoadContentEvent());
                      })
                ],
              ),
            );
          } else if (state is NextContentState) {
            return Column(
              children: [
                Center(
                  child: GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Swipe Indicator
                        SizedBox(
                          height: ResStyle.spacing,
                        ),
                        _buildSwipeIndicator(),

                        // Card with Swipe Animation
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: _animationController.status !=
                                      AnimationStatus.forward
                                  ? _dragOffset
                                  : _swipeAnimation.value,
                              child: Transform.rotate(
                                angle: _dragOffset.dx /
                                    1500, // Subtle rotation during drag
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                          color: TITLE_COLOR, width: 5)),
                                  child: Container(
                                    width: ResStyle.width * 0.8,
                                    height: ResStyle.height * 0.5,
                                    padding: EdgeInsets.all(ResStyle.spacing),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: HIGHTLIGHT_COLOR,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Image
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            state.content.image,
                                            height: ResStyle.height * 0.3,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {

                                              return Image.asset('lib/assets/playstore-icon.png',height: ResStyle.height * 0.2 , width:  ResStyle.height *0.2,);
                                              // return Icon(Icons.error,
                                              //     size: ResStyle.height * 0.2);
                                            },
                                          ),
                                        ),
                                        SizedBox(height: ResStyle.spacing),
                                        // Title
                                        Text(
                                          state.content.name,
                                          style: TextStyle(
                                            fontSize: ResStyle.font,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: ResStyle.spacing / 2),

                                        // Description
                                        Text(
                                          state.content.desc,
                                          style: TextStyle(
                                              fontSize: ResStyle.small_font),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: Container()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dislike Button (Quarter-circle at bottom left)
                    CustomQuarterCircleButton(
                      isRight: false,
                      color: DANGER_COLOR.withOpacity(0.7),
                      icon: Icons.close,
                      onPressed: () => _manualSwipe(false),
                      label: 'Dislike',
                    ),
                    // Like Button (Quarter-circle at bottom right)
                    CustomQuarterCircleButton(
                      isRight: true,
                      color: SUCCESS_COLOR,
                      icon: Icons.favorite_border_outlined,
                      onPressed: () => _manualSwipe(true),
                      label: 'Like',
                    ),
                  ],
                ),
              ],
            );
          }else if(state is ContentSubmittedState){
            BlocProvider.of<ContentBloc>(context).add(SubmitContentTestEvent(like_list: state.like_list, dislike_list: state.dislike_list));
            return BugLoading();
          } 
          else {
            // return const Center(
            //   child: Text(
            //     'No more content',
            //     style: TextStyle(fontSize: 24),
            //   ),
            // );

            return Center(
              child: ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<ContentInitBloc>(context)
                        .add(LoadContentEvent());
                  },
                  child: Text('Refresh')),
            );
          }
        }));
  }
}
