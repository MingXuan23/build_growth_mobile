import 'package:build_growth_mobile/api_services/gpt_repo.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';
import 'package:build_growth_mobile/models/user_backup.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/services/backup_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static bool first_user = false;
  AuthBloc(AuthState loginInitial) : super(loginInitial) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      UserToken.email = event.email;
      var result = await AuthRepo.login(event.email, event.password);

      if (result['success']) {
        await UserPrivacy.loadFromPreferences(UserToken.user_code ?? '');
        emit(LoginSuccess());

        
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
          await UserPrivacy.loadFromPreferences(UserToken.user_code ?? '');

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
        if (UserToken.online) {
          var result = await AuthRepo.changePassword(
              event.oldPassword, event.newPassword);
          emit(
              AuthChangePasswordResult(message: result.$2, success: result.$1));
        } else {
          emit(AuthChangePasswordResult(
              message:
                  'Look like you are not connected with us. Please restart the app.',
              success: false));
        }
      },
    );

    on<UserTourGuide>(
      (event, emit) async{
        emit(UserTourGuiding());
        await Future.delayed(Duration(milliseconds: 300));
        emit(UserTourGuideEnd());
      },
    );
    on<AuthServiceNotAvailable>(
      (event, emit) async {
        if (state is! RegisterReject) {
          emit(RegisterReject(event.cause ??
              'Register Service is not available for now. Please try again later'));
        } else {
          emit(RegisterReject(''));
        }

        await Future.delayed(const Duration(seconds: 5));
        emit(LoginInitial());
      },
    );

    on<UpdateProfileRequest>(
      (event, emit) async {
        final body = {
          'name': event.name,
          'address': event.address,
          'state': event.state,
          'telno': event.telno,
        };

        var res = await AuthRepo.updateProfile(body);

        if (res == 200) {
          emit(AuthUpdateProfileResult(
              success: true, message: 'Profile Updated Successfully'));
        } else {
          emit(AuthUpdateProfileResult(
              success: false, message: 'Some error occurs'));
        }
      },
    );

    on<UserPrivacyUpdated>((event, emit) {
      emit(UserPrivacyReload());
    },);

    // on<AutoLoginRequest>(
    //   (event, emit) async {
    //     await UserPrivacy.loadFromPreferences('mx');

    //     emit(LoginInitial());
    //   },
    // );

    on<LogoutRequested>(
      (event, emit) async {
        await UserToken.reset();
        await GoogleDriveBackupHelper.signOut();
        MessageBloc.userMessages = [];
        MessageBloc.gptReplies = [];
        emit(LoginInitial(email: UserToken.email));
      },
    );

    on<UserStartBackup>(
      (event, emit) async {
        if (state is UserRestoreRunning || state is UserBackUpRunning) {
          emit(AuthUpdateProfileResult(
            message:
                'Please wait until the current backup or restore process finishes before starting a new one.',
            success: false,
          ));
          return;
        }

        // Emit the running state

        // Check if Google Drive backup permission is granted
        if (!UserPrivacy.googleDriveBackup) {
          emit(AuthUpdateProfileResult(
            message:
                'To backup data, you need to grant permission for Google Drive backup.',
            success: false,
          ));
          return;
        }
        emit(UserBackUpRunning());
        // Start the backup process
        try {
          await GoogleDriveBackupHelper.startBackup();
          emit(UserBackUpEnded());
        } catch (e) {
          emit(AuthUpdateProfileResult(
            message:
                'An error occurred while trying to restore your data. Please try again later.',
            success: false,
          ));
        }
      },
    );

    on<UserStartRestore>(
      (event, emit) async {
        // Check if a backup or restore is already in progress
        if (state is UserRestoreRunning || state is UserBackUpRunning) {
          emit(AuthUpdateProfileResult(
            message:
                'Please wait until the current backup or restore process finishes before starting a new one.',
            success: false,
          ));
          return;
        }

        // Emit the running state

        // Check if Google Drive backup permission is granted
        if (!UserPrivacy.googleDriveBackup) {
          emit(AuthUpdateProfileResult(
            message:
                'To restore data, you need to grant permission for Google Drive backup.',
            success: false,
          ));
          return;
        }
        emit(UserRestoreRunning());
        // Start the backup process
        try {
          await UserBackup.restoreData(event.backupData);
          await GoogleDriveBackupHelper.startRestore();
          emit(UserRestoreEnded());
        } catch (e) {
          emit(AuthUpdateProfileResult(
            message:
                'An error occurred while trying to restore your data. Please try again later.',
            success: false,
          ));
        }
      },
    );
  }
}
