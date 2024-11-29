import 'package:build_growth_mobile/api_services/gpt_repo.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthState loginInitial) : super(loginInitial) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      UserToken.email = event.email;
      var result = await AuthRepo.login(event.email, event.password);

      if (result['success']) {
        await UserPrivacy.loadFromPreferences(UserToken.user_code??'');
        emit(LoginSuccess());

          await GptRepo.loadModel();

      } else {
        emit(LoginFailure(result['message']));
      }
    });

    on<AutoLoginRequest>(
      (event, emit) async {
        emit(AuthLoading());
        await UserToken.load();

        if (UserToken.remember_token == null) {
          emit(LoginInitial(email: UserToken.email));
          return;
        }

        UserToken.online = await AuthRepo.validateEnvironment();
        if (!UserToken.online) {
          emit(LoginSuccess()); //enable offline use, but limit functionalities
          return;
        }
        var res = await AuthRepo.validateSession(
            UserToken.remember_token ?? '', UserToken.email ?? '');

        if (res.$1) {
          emit(LoginSuccess());

          await GptRepo.loadModel();
        } else {
          emit(LoginInitial(email: UserToken.email, message: res.$2));
        }
      },
    );

    on<CheckRegisterEmail>(
      (event, emit) async {
        emit(AuthLoading());
        var check = await AuthRepo.sendVerificationCode(event.email, '');

        if (check == 400) {
          emit(const RegisterPendingCodeWithMessgae(
              'Your email have an uncompleted registration'));
          return;
        } else if (check == 401) {
          emit(const RegisterReject(
              'This email have been used by other user already'));
          return;
        }

        emit(RegisterContinued());
      },
    );

    on<SendVerificationCode>(
      (event, emit) async {
        emit(CodeLoading());
        var check =
            await AuthRepo.sendVerificationCode(event.email, event.code);

        if (check == 200) {
          emit(RegisterSuccess());

          return;
        } else if (check == 400) {
          emit(const RegisterReject('Invalid verification code'));
          return;
        } else if (check == 401) {
          emit(const RegisterReject(
              'Your registration have been completed. Please log in now.'));
          return;
        } else {
          emit(const RegisterReject(
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

    on<ResendVerificationCode>(
      (event, emit) async {
        emit(AuthRefreshCode(second: 60));

        var result = await AuthRepo.resendVerificationCode(event.email);

        emit(AuthRefreshCode(status: result == 200, second: 0));
      },
    );

    on<AuthForgetPassword>(
      (event, emit) async {
        if (state is AuthForgetPasswordPerforming) {
          return;
        }
        emit(AuthForgetPasswordPerforming());
        var result = await AuthRepo.forgetPassword(event.email);
        emit(AuthForgetPasswordResult(message: result));
      },
    );

    on<ChangePasswordRequest>(
      (event, emit) async {

        if(UserToken.online){
          var result =
            await AuthRepo.changePassword(event.oldPassword, event.newPassword);
        emit(AuthChangePasswordResult(message: result.$2, success: result.$1));
        }else{
        emit(AuthChangePasswordResult(message:'Look like you are not connected with us. Please restart the app.', success: false));

        }
        
      },
    );
    // on<AutoLoginRequest>(
    //   (event, emit) async {
    //     await UserPrivacy.loadFromPreferences('mx');

    //     emit(LoginInitial());
    //   },
    // );

    on<LogoutRequested>(
      (event, emit) async {
        await UserToken.reset();

        emit(LoginInitial(email: UserToken.email));
      },
    );
  }
}
