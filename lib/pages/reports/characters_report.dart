import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/button.dart';

import '../../helpers/report_helper.dart';
import '../../providers/project_state.dart';

class CharactersReport extends StatefulWidget {
  const CharactersReport({super.key});

  @override
  State<CharactersReport> createState() => _CharactersReportState();
}

class _CharactersReportState extends State<CharactersReport> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context);

    /// TODO: generate characters report
    return ListView(
      children: [
        WrtButton(
          callback: () {
            if (provider.project == null) return;
            ReportHelper().characterReport(provider.project!);
          },
          label: 'GENERATE (TEST)',
        ),
      ],
    );
  }
}
