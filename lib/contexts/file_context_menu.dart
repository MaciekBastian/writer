import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/tools/confirm_delete_dialog.dart';
import '../providers/project_state.dart';
import '../widgets/snippets/character_snippet.dart';
import '../widgets/snippets/references.dart';
import '../widgets/snippets/thread_snippet.dart';
import 'context_menu_button.dart';

class CharacterFileContextMenu extends StatelessWidget {
  const CharacterFileContextMenu({
    super.key,
    required this.id,
  });
  final String id;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final theme = Theme.of(context);

    return Container(
      width: 250.0,
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: const Color(0xFF242424),
        border: Border.all(color: theme.canvasColor, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15.0,
            spreadRadius: 10.0,
          )
        ],
      ),
      child: Column(
        children: [
          ContextMenuButton(
            label: 'context_menu.open_in_new_window'.tr(),
            callback: () {
              // TODO: implement multi-window
              // provider.openCharacter(id);
            },
          ),
          ContextMenuButton(
            label: 'character.open'.tr(),
            callback: () {
              provider.openCharacter(id);
            },
          ),
          ContextMenuButton(
            label: 'character.delete'.tr(),
            callback: () async {
              final wantToDelete = await showDialog<bool?>(
                context: context,
                builder: (context) => const ConfirmDeleteDialog(),
              );

              if (wantToDelete == true) {
                provider.deleteCharacter(id);
              }
            },
          ),
          const Divider(
            color: Color(0xFF424242),
            height: 10.0,
            thickness: 2.0,
            indent: 5.0,
            endIndent: 5.0,
          ),
          ContextMenuButton(
            label: 'context_menu.show_snippet'.tr(),
            callback: () {
              final renderObject = context.findRenderObject() as RenderBox;
              final size = renderObject.size;
              final offset = renderObject.localToGlobal(Offset.zero);
              final screenSize = MediaQuery.of(context).size;

              final dx = (offset.dx + size.width) >= screenSize.width - 280.0
                  ? screenSize.width - 280.0
                  : offset.dx + size.width;
              final dy = (offset.dy - 150.0 - (size.height / 2)) >=
                      screenSize.height - 400.0
                  ? screenSize.height - 400.0
                  : (offset.dy - 150.0 - (size.height / 2));

              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                barrierDismissible: true,
                anchorPoint: Offset(dx, dy),
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.all(0.0),
                    backgroundColor: Colors.transparent,
                    child: Container(
                      width: 250.0,
                      height: 380.0,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20.0,
                            spreadRadius: 2.0,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 35.0,
                            margin: const EdgeInsets.only(right: 10.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: const Icon(
                                  Icons.close,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: CharacterSnippet(
                              characterId: id,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          ContextMenuButton(
            label: 'context_menu.find_references'.tr(),
            callback: () {
              final renderObject = context.findRenderObject() as RenderBox;
              final size = renderObject.size;
              final offset = renderObject.localToGlobal(Offset.zero);
              final screenSize = MediaQuery.of(context).size;

              final dx = (offset.dx + size.width) >= screenSize.width - 280.0
                  ? screenSize.width - 280.0
                  : offset.dx + size.width;
              final dy = (offset.dy - 150.0 - (size.height / 2)) >=
                      screenSize.height - 400.0
                  ? screenSize.height - 400.0
                  : (offset.dy - 150.0 - (size.height / 2));

              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                barrierDismissible: true,
                anchorPoint: Offset(dx, dy),
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.all(0.0),
                    backgroundColor: Colors.transparent,
                    child: Container(
                      width: 250.0,
                      height: 380.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20.0,
                            spreadRadius: 2.0,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 35.0,
                            margin: const EdgeInsets.only(right: 10.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: const Icon(
                                  Icons.close,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ReferencesToFile(
                              id: id,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ThreadFileContextMenu extends StatelessWidget {
  const ThreadFileContextMenu({
    super.key,
    required this.id,
  });
  final String id;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final theme = Theme.of(context);

    return Container(
      width: 250.0,
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: const Color(0xFF242424),
        border: Border.all(color: theme.canvasColor, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15.0,
            spreadRadius: 10.0,
          )
        ],
      ),
      child: Column(
        children: [
          ContextMenuButton(
            label: 'thread.open'.tr(),
            callback: () {
              provider.openThread(id);
            },
          ),
          ContextMenuButton(
            label: 'thread.delete'.tr(),
            callback: () async {
              final wantToDelete = await showDialog<bool?>(
                context: context,
                builder: (context) => const ConfirmDeleteDialog(),
              );

              if (wantToDelete == true) {
                provider.deleteThread(id);
              }
            },
          ),
          const Divider(
            color: Color(0xFF424242),
            height: 10.0,
            thickness: 2.0,
            indent: 5.0,
            endIndent: 5.0,
          ),
          ContextMenuButton(
            label: 'context_menu.show_snippet'.tr(),
            callback: () {
              final renderObject = context.findRenderObject() as RenderBox;
              final size = renderObject.size;
              final offset = renderObject.localToGlobal(Offset.zero);
              final screenSize = MediaQuery.of(context).size;

              final dx = (offset.dx + size.width) >= screenSize.width - 280.0
                  ? screenSize.width - 280.0
                  : offset.dx + size.width;
              final dy = (offset.dy - 150.0 - (size.height / 2)) >=
                      screenSize.height - 400.0
                  ? screenSize.height - 400.0
                  : (offset.dy - 150.0 - (size.height / 2));

              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                barrierDismissible: true,
                anchorPoint: Offset(dx, dy),
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.all(0.0),
                    backgroundColor: Colors.transparent,
                    child: Container(
                      width: 250.0,
                      height: 380.0,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20.0,
                            spreadRadius: 2.0,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 35.0,
                            margin: const EdgeInsets.only(right: 10.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: const Icon(
                                  Icons.close,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ThreadSnippet(
                              threadId: id,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          ContextMenuButton(
            label: 'context_menu.find_references'.tr(),
            callback: () {
              final renderObject = context.findRenderObject() as RenderBox;
              final size = renderObject.size;
              final offset = renderObject.localToGlobal(Offset.zero);
              final screenSize = MediaQuery.of(context).size;

              final dx = (offset.dx + size.width) >= screenSize.width - 280.0
                  ? screenSize.width - 280.0
                  : offset.dx + size.width;
              final dy = (offset.dy - 150.0 - (size.height / 2)) >=
                      screenSize.height - 400.0
                  ? screenSize.height - 400.0
                  : (offset.dy - 150.0 - (size.height / 2));

              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                barrierDismissible: true,
                anchorPoint: Offset(dx, dy),
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.all(0.0),
                    backgroundColor: Colors.transparent,
                    child: Container(
                      width: 250.0,
                      height: 380.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20.0,
                            spreadRadius: 2.0,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 35.0,
                            margin: const EdgeInsets.only(right: 10.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: const Icon(
                                  Icons.close,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ReferencesToFile(
                              id: id,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
