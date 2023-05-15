import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(10.0),
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: const Icon(
            Icons.edit,
            size: 125.0,
          ),
        ),
        Text(
          'welcome.welcome_text'.tr(),
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 20.0),
        Text(
          '© Maciej Bastian, 2023',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 5.0),
        Text(
          'welcome.app_description'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 5.0),
        FutureBuilder(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Text(
                'Version: --.--.--, build #--',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground,
                ),
              );
            }
            return Text(
              'Version: ${snapshot.data!.version}, build #${snapshot.data!.buildNumber}',
              style: theme.textTheme.bodyMedium,
            );
          },
        ),
        const SizedBox(height: 5.0),
        const Row(
          children: [
            FlutterLogo(
              size: 40.0,
              style: FlutterLogoStyle.markOnly,
            ),
            SizedBox(width: 10.0),
            Text(
              'Powered by Flutter. An open-source framework by Google: flutter.dev',
            ),
          ],
        )
      ],
    );
  }
}
