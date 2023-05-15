import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_audio/simple_audio.dart';
import 'package:writer/widgets/prompts/tab_switcher_dialog.dart';

import 'constants/colors.dart';
import 'helpers/window_helper.dart';
import 'pages/global_settings.dart';
import 'pages/home.dart';
import 'providers/cache.dart';
import 'providers/project_state.dart';
import 'providers/selection.dart';
import 'providers/version_control.dart';
import 'widgets/prompts/command_palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleAudio.init(
    showMediaNotification: false,
  );

  await WindowHelper().initialize();

  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = [];

  final preferences = await SharedPreferences.getInstance();
  final language = preferences.getString('app_language') ?? Platform.localeName;

  runApp(
    EasyLocalization(
      startLocale: Locale(language),
      supportedLocales: const [
        Locale('en'),
        Locale('pl'),
        Locale('de'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProjectState()),
        ChangeNotifierProvider(create: (context) => ProjectCache()),
        ChangeNotifierProvider(create: (context) => VersionControl()),
        ChangeNotifierProvider(create: (context) => SelectionManager()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Writer',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark().copyWith(
            primary: WrtTheme.productBlue,
          ),
        ),
        routes: {
          HomeScreen.pageName: (context) => const HomeScreen(),
          GlobalSettingsPage.pageName: (context) => const GlobalSettingsPage(),
          // dialogs
          TabSwitcherDialog.pageName: (context) => const TabSwitcherDialog(),
          CommandPalette.pageName: (context) => const CommandPalette(),
        },
      ),
    );
  }
}
