import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/search_result.dart';
import '../expandable_section.dart';

import '../../helpers/project_helper.dart';
import '../../models/file_tab.dart';
import '../../providers/project_state.dart';

class ReferencesToFile extends StatefulWidget {
  const ReferencesToFile({super.key, required this.id});
  final String id;

  @override
  State<ReferencesToFile> createState() => _ReferencesToFileState();
}

class _ReferencesToFileState extends State<ReferencesToFile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context, listen: false);
    if (provider.project == null) return Container();

    return FutureBuilder<List<SearchResult>?>(
      future: ProjectHelper().getReferences(provider.project!, widget.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text('...'),
          );
        } else if (snapshot.data == null) {
          return const Center(
            child: Text('Error!'),
          );
        }

        final data = snapshot.data!;

        final characters = data.where((element) {
          return element.type == FileType.characterEditor;
        }).toList();
        final threads = data.where((element) {
          return element.type == FileType.threadEditor;
        }).toList();
        final chapters = data.where((element) {
          return element.type == FileType.timelineEditor;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(12.0),
          children: [
            Text(
              'references.references'.tr(),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            const Divider(
              height: 16.0,
              endIndent: 40.0,
              color: Color(0xFF424242),
              thickness: 2.0,
            ),
            const SizedBox(height: 8.0),
            WrtExpandableSection(
              header: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'references.characters'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              allClickable: true,
              hoverEffect: true,
              buttonExpanded: const Icon(Icons.expand_less),
              buttonFolded: characters.isEmpty
                  ? Text(
                      'references.none'.tr(),
                    )
                  : const Icon(Icons.expand_more),
              content: Column(
                children: characters.map((e) {
                  return Row(
                    children: [
                      const SizedBox(width: 30.0),
                      const Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                        size: 20.0,
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          provider.characters[e.id] ?? 'ERROR',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          mouseCursor: SystemMouseCursors.click,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            if (e.id == null) return;
                            provider.openCharacter(e.id!);
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              'references.open_in_editor'.tr(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: const Color.fromARGB(255, 88, 111, 230),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            WrtExpandableSection(
              header: Row(
                children: [
                  const Icon(
                    Icons.upcoming_outlined,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'references.threads'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              allClickable: true,
              hoverEffect: true,
              buttonExpanded: const Icon(Icons.expand_less),
              buttonFolded: threads.isEmpty
                  ? Text(
                      'references.none'.tr(),
                    )
                  : const Icon(Icons.expand_more),
              content: Column(
                children: threads.map((e) {
                  return Row(
                    children: [
                      const SizedBox(width: 30.0),
                      const Icon(
                        Icons.upcoming_outlined,
                        color: Colors.grey,
                        size: 20.0,
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          provider.threads[e.id] ?? 'ERROR',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          mouseCursor: SystemMouseCursors.click,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            if (e.id == null) return;
                            provider.openThread(e.id!);
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              'references.open_in_editor'.tr(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: const Color.fromARGB(255, 88, 111, 230),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            WrtExpandableSection(
              header: Row(
                children: [
                  const Icon(
                    Icons.book_outlined,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'references.chapters'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              allClickable: true,
              hoverEffect: true,
              buttonExpanded: const Icon(Icons.expand_less),
              buttonFolded: chapters.isEmpty
                  ? Text(
                      'references.none'.tr(),
                    )
                  : const Icon(Icons.expand_more),
              content: Column(
                children: chapters.map((e) {
                  return Row(
                    children: [
                      const SizedBox(width: 30.0),
                      const Icon(
                        Icons.book_outlined,
                        color: Colors.grey,
                        size: 20.0,
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          provider.chaptersAsMap[e.id] ?? 'ERROR',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          mouseCursor: SystemMouseCursors.click,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            if (e.id == null) return;
                            provider.openTab(
                              FileTab(
                                id: null,
                                path: null,
                                type: FileType.timelineEditor,
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              'references.open_in_editor'.tr(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: const Color.fromARGB(255, 88, 111, 230),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
