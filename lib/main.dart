import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/pages/widget_tree/start_page.dart';
import 'package:build_growth_mobile/repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp(home: StartPage(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.home});
  final Widget home;
  // This widget is the root of your application.
   @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(LoginInitial(), AuthRepo())),
        // BlocProvider<DermaBloc>(
        //     create: (context) => DermaBloc(DermaInitial(), DermaRepo())),
        // BlocProvider<InfoBloc>(
        //     create: (context) => InfoBloc(InfoInitial(), InfoRepo()))
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: UpgradeAlert(
              showIgnore: false,
              showLater: false,
              showReleaseNotes: false,
              upgrader: Upgrader(minAppVersion: '1.0.0'),
              child: home)),
    );
  }
}
