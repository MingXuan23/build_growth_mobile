import 'dart:convert';

import 'package:build_growth_mobile/api_services/auth_repo.dart';
import 'package:build_growth_mobile/models/golden_leaf.dart';

import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:share_plus/share_plus.dart';
part 'gold_leaf_event.dart';
part 'gold_leaf_state.dart';

class GoldLeafBloc extends Bloc<GoldLeafEvent, GoldLeafState> {
  static GoldenLeaf? leaf;
  static bool collected = false;
  static List<String> completedMissionList = [];
  static List<String> pendingMissionList = [];
  static Map<String, dynamic> leafData = {};

  GoldLeafBloc(GoldLeafState leafInitial) : super(leafInitial) {
    on<LoadGoldLeafEvent>(
      (event, emit) async {
//         await GoldenLeaf.deleteFromSharedPreferences();
//  collected = false;
//         await GoldenLeaf.saveLocalLeafData(leafData);
        emit(GoldLeafLoadingState());
        var temp_leaf = await GoldenLeaf.loadFromSharedPreferences();
        leafData = await GoldenLeaf.getLocalLeafData();
        if (leafData['last_date'] != null) {
          var date = DateTime.parse(leafData['last_date']);
          if (!FormatterHelper.isToday(date)) {
            var data  = await AuthRepo.getLeafStatus();

            if(data['status']){
            leafData = data['data'];

            }else{
            leafData = {};

            }
          }else {
            collected = true;
          }
        }else{
           var data  = await AuthRepo.getLeafStatus();

            if(data['status']){
            leafData = data['data'];

            }else{
            leafData = {};

            }
        }

        if (temp_leaf == null) {
          GoldenLeaf newleaf = GoldenLeaf(
              totalSubLeaf: 0,
              date: DateTime.now(),
              user_code: UserToken.user_code,
              chatRequest: null);
          var data =
              await GoldenLeaf.getSubLeaf(leaf?.chatRequest, leaf?.shareTime);

          newleaf.totalSubLeaf = data['sum_leaf'];

          leaf = newleaf;
          leaf!.saveToSharedPreferences();
          completedMissionList = data['completedMissions'];
          pendingMissionList = data['pendingMissions'];
        } else {
          leaf = temp_leaf;
          var data =
              await GoldenLeaf.getSubLeaf(leaf?.chatRequest, leaf?.shareTime);

          leaf!.totalSubLeaf = data['sum_leaf'];
          completedMissionList = data['completedMissions'];
          pendingMissionList = data['pendingMissions'];
          leaf!.saveToSharedPreferences();
        }

        emit(GoldLeafLoadedState());
      },
    );

    on<ChatGoldLeafEvent>(
      (event, emit) {
        if (leaf == null) {
          return;
        }

        leaf!.addChatRequest();
        leaf!.saveToSharedPreferences();
      },
    );

    on<ShareGoldLeafEvent>(
      (event, emit) {
        if (leaf == null) {
          return;
        }

        leaf!.shareTime = DateTime.now();
        leaf!.saveToSharedPreferences();
      },
    );

    on<CompleteGoldLeafEvent>(
      (event, emit) async {
        var detail = {
          'leaf': leaf?.toBugMap(),
          'completed': completedMissionList,
          'pending': pendingMissionList,
        };

        var detailJson = jsonEncode(detail);

        var message = await AuthRepo.addNewLeaf(detailJson);
        collected = true;
        await GoldenLeaf.saveLocalLeafData(leafData);

        emit(GoldLeafCompletedState(message: message));
        ;
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
