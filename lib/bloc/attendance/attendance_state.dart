part of 'attendance_bloc.dart';

sealed class AttendanceState{
  const AttendanceState();
  
 
}

final class AttendanceInitialState extends AttendanceState {}

final class AttendanceSubmittedState extends AttendanceState {

  final String message;
  AttendanceSubmittedState( this.message);
  
}


final class AttendanceErrorState extends AttendanceState {

  final String message;
  AttendanceErrorState( this.message);
  
}

