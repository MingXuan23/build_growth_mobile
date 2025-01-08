part of 'attendance_bloc.dart';

sealed class AttendanceState{
  const AttendanceState();
  
 
}

final class AttendanceInitialState extends AttendanceState {}

final class AttendanceSubmittedState extends AttendanceState {

  final String message;
  final String link;
  AttendanceSubmittedState( this.message, this.link);
  
}


final class AttendanceErrorState extends AttendanceState {

  final String message;
  AttendanceErrorState( this.message);
  
}

