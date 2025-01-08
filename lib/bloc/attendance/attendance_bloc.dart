import 'package:build_growth_mobile/api_services/content_repo.dart';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/card.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc(AttendanceState initial) : super(initial) {
    on<AttendanceSubmitEvent>(
      (event, emit) async {
        var result = await ContentRepo.saveContentEnrollment(
            event.card_id, event.verification_code);

        if (result.$1 == 200) {
          emit(AttendanceSubmittedState(
             'You have enrolled into this content!',
             result.$2??''
          ));
        }else if(result.$1  ==201){
          emit(AttendanceSubmittedState(
             'Enroll into content successfully!',
             result.$2??''
          ));
        }else if(result.$1  == 400){
            emit(AttendanceErrorState(
             'Information Expired. Please contact the nearby staff'
          ));
        }

        else{
          emit(AttendanceErrorState(
             'Error occur. Please try again later.'
          ));
        }
      },
    );
  }
}


//brief explanation

//user trigger a action and u should add the event to the bloc provider like this
/*BlocProvider.of<AuthBloc>(context).add(
        LoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      ); 
*/

//then u handle the event in the bloc class

//the state was emitted, the changes will listened by bloc listener in the pages

//after created a new bloc remember add it to the main.dart
