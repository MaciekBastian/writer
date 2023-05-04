import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/dropdown_select.dart';

class GlobalSettingsPage extends StatefulWidget {
  static const pageName = '/plotweaver/settings/main';
  const GlobalSettingsPage({super.key});

  @override
  State<GlobalSettingsPage> createState() => _GlobalSettingsPageState();
}

class _GlobalSettingsPageState extends State<GlobalSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          // top bar
          Container(
            padding: const EdgeInsets.only(
              top: 35.0,
              bottom: 10.0,
              left: 10.0,
            ),
            color: Colors.grey[900],
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '< ${'preferences.global.back'.tr()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color.fromARGB(255, 88, 111, 230),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ), // page
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                Text(
                  'preferences.global.preferences'.tr(),
                  style: theme.textTheme.headlineLarge,
                ),
                Text(
                  'preferences.global.preferences_info'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  margin: EdgeInsets.only(right: screenSize.width * 0.5),
                  height: 55.0,
                  child: WrtDropdownSelect(
                    initiallySelected: context.locale,
                    onSelected: (value) async {
                      context.setLocale(value);
                      final preferences = await SharedPreferences.getInstance();
                      preferences.setString('app_language', value.languageCode);
                    },
                    values: context.supportedLocales,
                    title: 'preferences.global.app_language'.tr(),
                    labels: context.supportedLocales.asMap().map(
                      (key, value) {
                        return MapEntry(
                          value,
                          value.languageCode.contains('pl')
                              ? 'preferences.global.language_values.pl'.tr()
                              : value.languageCode.contains('en')
                                  ? 'preferences.global.language_values.en'.tr()
                                  : '',
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
