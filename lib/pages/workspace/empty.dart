import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/general_helper.dart';
import '../../models/file_tab.dart';
import '../../providers/project_state.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context, listen: false);
    return DragTarget<FileTab>(
      onWillAccept: (data) {
        return data != null;
      },
      onAccept: (data) {
        if (data.type == FileType.characterEditor) {
          if (data.id == null) return;
          provider.openCharacter(data.id!);
        } else if (data.type == FileType.threadEditor) {
          if (data.id == null) return;
          provider.openThread(data.id!);
        } else if (data.type == FileType.editor) {
          if (data.id == null) return;
          provider.openChapterEditor(data.id!);
        } else {
          provider.openTab(data);
        }
      },
      builder: (context, candidateData, rejectedData) {
        if (candidateData.isNotEmpty) {
          final candidate = candidateData.first;
          if (candidate != null) {
            return Stack(
              children: [
                Center(
                  child: Icon(
                    GeneralHelper()
                        .getTypeIcon(candidate.type, candidate.path)
                        .icon,
                    color: Colors.grey[900],
                    size: 180.0,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF1638E2),
                        width: 3.0,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              size: 180.0,
              color: Colors.grey[900],
            ),
          ],
        );
      },
    );
  }
}
