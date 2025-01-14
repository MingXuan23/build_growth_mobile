part of 'gold_leaf_bloc.dart';

sealed class GoldLeafState{
  const GoldLeafState();
  
 
}

class GoldLeafInitState extends GoldLeafState{

}

class GoldLeafLoadedState extends GoldLeafState{

}

class GoldLeafLoadingState extends GoldLeafState{

}

class GoldLeafCompletedState extends GoldLeafState{
  final String message;

  GoldLeafCompletedState({required this.message});
  
}
// class ExampleState extends TemplateState {
//   final String error;

//   const ExampleState(this.error);

//   @override
//   List<Object> get props => [error];
// }

