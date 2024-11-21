import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthRepo repo;

  AuthBloc(AuthState loginInitial, this.repo) : super(loginInitial) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      var result = await AuthRepo.login(event.email, event.password);
      emit(LoginSuccess());

      if (result['success']) {
        await UserPrivacy.loadFromPreferences('mx');
        emit(LoginSuccess());
      } else {
        emit(LoginFailure('Invalid Lpgin'));
      }
    });

    on<CheckRegisterEmail>(
      (event, emit) async {
        emit(AuthLoading());
        var check = await AuthRepo.sendVerificationCode(event.email, '');

        if (check == 400) {
          emit(const RegisterPendingCodeWithMessgae(
              'Your email have an uncompleted registration'));
          return;
        } else if (check == 401) {
          emit(const RegisterFailure(
              'This email have been used by other user already'));
          return;
        }

        emit(RegisterContinued());
      },
    );

    on<SendVerificationCode>(
      (event, emit) async {
        emit(AuthLoading());
        var check =
            await AuthRepo.sendVerificationCode(event.email, event.code);

        if (check == 200) {
          emit(RegisterSuccess());

          return;
        } else if (check == 400) {
          emit(const RegisterFailure('Invalid verification code'));
          return;
        } else if (check == 401) {
          emit(const RegisterFailure(
              'Your registration have been completed. Please log in now.'));
          return;
        } else {
          emit(const RegisterFailure(
              'Some errors occur. Please try again later'));
          return;
        }
      },
    );
    on<RegisterRequested>(
      (event, emit) async {
        emit(AuthLoading());
        final Map<String, dynamic> requestBody = {
          'email': event.email,
          'password': event.password,
          'name': event.name,
          'state': event.state,
          'telno': event.telno,
          'address': event.address,
        };

        var result = await AuthRepo.register(requestBody);

        if (result['status'] == 201) {
          emit(RegisterPendingCode());
          return;
        } else if (result['status'] == 403) {
          emit(RegisterPendingCodeWithMessgae(result['message']));
          return;
        } else {
          emit(RegisterFailure(result['message']));
          return;
        }
      },
    );

    on<ResendVerificationCode>((event, emit) async {
      emit(AuthRefreshCode(second: 60));

      var result = await AuthRepo.resendVerificationCode(event.email);

      emit(AuthRefreshCode(status: result == 200, second: 0));
    },);
    on<AutoLoginRequest>(
      (event, emit) async {
        await UserPrivacy.loadFromPreferences('mx');

        emit(LoginInitial());
      },
    );

    on<LogoutRequested>(
      (event, emit) async {
        //await User.logout();
        emit(LoginFailure('Logout'));
      },
    );
  }
}
