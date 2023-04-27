import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sidebar_tab.dart';

import '../providers/project_state.dart';
import '../providers/version_control.dart';

class Statusbar extends StatelessWidget {
  const Statusbar({super.key});

  @override
  Widget build(BuildContext context) {
    final providerFunctions = Provider.of<ProjectState>(context, listen: false);
    final provider = Provider.of<ProjectState>(context);
    final versionControl = Provider.of<VersionControl>(context);
    final theme = Theme.of(context);

    if (!provider.isProjectOpened) {
      return Container(
        height: 20.0,
        color: theme.colorScheme.primary,
      );
    }

    return Container(
      height: 20.0,
      color: theme.colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 10.0),
              if (provider.statusBarSave)
                _buildStatusBarButton(
                  provider: provider,
                  theme: theme,
                  text: provider.unsavedCount.toString(),
                  icon: Icons.save_rounded,
                  callback: () {
                    if (provider.unsavedCount != 0) {
                      providerFunctions.saveAll();
                    }
                  },
                ),
              if (provider.statusBarErrors)
                _buildStatusBarButton(
                  provider: provider,
                  theme: theme,
                  text: provider.errorsCount.toString(),
                  icon: Icons.error_outline,
                  callback: () {
                    providerFunctions.switchErrorPanel();
                  },
                ),
              const SizedBox(width: 5.0),
              if (provider.isProjectBeingAnalized)
                const Icon(
                  Icons.refresh_rounded,
                  size: 15.0,
                ),
            ],
          ),
          Row(
            children: [
              if (provider.statusBarWordCount &&
                  provider.wordCountForEditor() != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.white24,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Text(
                        '${'status_bar.words'.tr()}: ${provider.wordCountForEditor()}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ),
                ),
              // TODO: maybe (?) notifications

              const SizedBox(width: 10.0),
              if (versionControl.isVersioningEnabled &&
                  versionControl.current != null &&
                  provider.statusBarVersion)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      providerFunctions.switchSidebarTab(
                        SidebarTab.versionControl,
                      );
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.white24,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Row(
                        children: [
                          const Icon(Icons.mediation, size: 15.0),
                          const SizedBox(width: 5.0),
                          Text(
                            versionControl.current!.code,
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 10.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBarButton({
    required ProjectState provider,
    required ThemeData theme,
    required String text,
    required IconData icon,
    required void Function() callback,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: callback,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.white24,
          child: Row(
            children: [
              const SizedBox(width: 4.0),
              Icon(
                icon,
                color: Colors.white,
                size: 16.0,
              ),
              const SizedBox(width: 5.0),
              Text(
                text,
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(width: 4.0, height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
