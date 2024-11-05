import 'package:build_growth_mobile/repo/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthRepo repo;

  AuthBloc(AuthState loginInitial, this.repo) : super(loginInitial) {
    
    on<LoginRequested>((event, emit) async {
      emit(LoginLoading());
      
      var result = true;
      if(result){
        emit(LoginSuccess());
        return;
      }
      else{
        emit(LoginFailure('Invalid Lpgin'));
      }
      
    });
    on<RegisterRequested>((event, emit) {
      emit(RegisterSuccess());
    },);


    on<LogoutRequested>(
      (event, emit) async {
        //await User.logout();
        emit(LoginFailure('Logout'));
      },
    );
  }
}
