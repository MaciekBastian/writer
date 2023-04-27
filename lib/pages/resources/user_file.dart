import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/project_state.dart';

class UserFilePage extends StatefulWidget {
  const UserFilePage({super.key});

  @override
  State<UserFilePage> createState() => _UserFilePageState();
}

class _UserFilePageState extends State<UserFilePage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context);
    final tab = provider.selectedTab!;
    if (tab.path == null) return Container();

    final file = File(tab.path!);
    if (!file.existsSync()) return Container();

    final fileName = file.uri.pathSegments.where((element) {
      return element.isNotEmpty;
    }).last;
    final extension = fileName
        .substring(
          fileName.lastIndexOf('.') + 1,
        )
        .toLowerCase();

    if ([
      'jpeg',
      'png',
      'jpg',
      'svg',
      'jfif',
      'pjpeg',
      'webp',
    ].contains(extension)) {
      return Image.file(
        file,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    } else if (['pdf'].contains(extension)) {
      // TODO: build pdf file view
      return FutureBuilder(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Container();
          } else {
            return Container();
          }
        },
      );
    }

    return Container();
  }
}
