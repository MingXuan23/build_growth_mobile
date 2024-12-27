part of 'attendance_bloc.dart';

sealed class AttendanceEvent {
  const AttendanceEvent();


}

class AttendanceSubmitEvent extends AttendanceEvent {

  final String verification_code;
  final String card_id;
  AttendanceSubmitEvent(this.verification_code, this.card_id);
  
}

class FetchEnrollmentEvent extends AttendanceEvent{
  
}

