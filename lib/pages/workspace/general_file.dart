import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/language.dart';
import '../../providers/project_state.dart';
import '../../widgets/dropdown_select.dart';
import '../../widgets/text_field.dart';

class GeneralFile extends StatefulWidget {
  const GeneralFile({super.key});

  @override
  State<GeneralFile> createState() => _GeneralFileState();
}

class _GeneralFileState extends State<GeneralFile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = Provider.of<ProjectState>(context);
    final provider = Provider.of<ProjectState>(context, listen: false);
    final thisTab = project.selectedTab;

    var generalInfoTile = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 25.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 20.0,
              ),
              const SizedBox(width: 5.0),
              Expanded(
                child: Text(
                  'general.info'.tr(),
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          SelectableText(
            'general.how_project_works'.tr(),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 6.0),
          SelectableText(
            '${'general.current_path'.tr()}\n${project.project!.path}',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: ListView(
            children: [
              const SizedBox(height: 20.0),
              Container(
                height: 55.0,
                padding: const EdgeInsets.only(left: 25.0),
                child: WrtTextField(
                  initialValue: project.project!.name,
                  title: 'general.project_name'.tr(),
                  onEdit: (val) {
                    if (thisTab == null) return;
                    provider.updateProjectConfig(
                      thisTab,
                      project.project!.copyWith(
                        name: val,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                height: 55.0,
                padding: const EdgeInsets.only(left: 25.0),
                child: WrtTextField(
                  initialValue: project.project!.author,
                  title: 'general.author'.tr(),
                  altText: 'general.unset'.tr(),
                  onEdit: (val) {
                    if (thisTab == null) return;
                    provider.updateProjectConfig(
                      thisTab,
                      project.project!.copyWith(
                        author: val,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                height: 55.0,
                padding: const EdgeInsets.only(left: 25.0),
                child: WrtDropdownSelect(
                  initiallySelected: project.project!.language,
                  values: ProjectLanguage.values,
                  labels: {
                    ProjectLanguage.en: 'general.language_values.en'.tr(),
                    ProjectLanguage.pl: 'general.language_values.pl'.tr(),
                    ProjectLanguage.other: 'general.language_values.other'.tr(),
                  },
                  title: 'general.language'.tr(),
                  onSelected: (value) {
                    if (thisTab == null) return;
                    provider.updateProjectConfig(
                      thisTab,
                      project.project!.copyWith(
                        language: value,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              if (provider.smallScreenView) generalInfoTile,
              const SizedBox(height: 40.0),
            ],
          ),
        ),
        if (!provider.smallScreenView)
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: generalInfoTile,
            ),
          ),
      ],
    );
  }
}
